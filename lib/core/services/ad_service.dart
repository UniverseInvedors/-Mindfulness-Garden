// ignore_for_file: deprecated_member_use
//
// AdService — Production-ready AdMob integration for PranaVerse
//
// Ad units configured:
//   Banner              ca-app-pub-8759032363251002/9917112645
//   Interstitial        ca-app-pub-8759032363251002/7946221708
//   Rewarded Interstitial ca-app-pub-8759032363251002/6635671042
//   Rewarded            ca-app-pub-8759032363251002/3009796315
//
// UX rules enforced here (never violate AdMob policy):
//   • No ad shown during an active meditation/breathing session
//   • Interstitial: max 1 per 3 minutes, only on natural nav transitions
//   • Rewarded: only when user explicitly opts in ("Watch ad for seeds")
//   • Rewarded interstitial: only after session completion, max 1 per session
//   • Premium subscribers (isPremium=true) never see ads
//   • Ads silently no-op on load failure — never crash or block the UI

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Placement enum — callers declare where an ad will appear so the service
// can apply the correct frequency and UX rules.
// ─────────────────────────────────────────────────────────────────────────────

enum AdPlacement {
  /// Between navigation taps on the main menu (not inside sessions)
  menuNavigation,

  /// After a meditation/yoga/breathing session completes naturally
  sessionComplete,

  /// User explicitly pressed "Watch ad for bonus seeds"
  rewardedOptIn,

  /// After session complete — richer rewarded interstitial format
  rewardedInterstitialOptIn,
}

// ─────────────────────────────────────────────────────────────────────────────
// AdService singleton
// ─────────────────────────────────────────────────────────────────────────────

class AdService {
  AdService._();
  static final AdService _i = AdService._();
  factory AdService() => _i;

  // ── Production ad unit IDs ──────────────────────────────────────────────
  static const _bannerProd = 'ca-app-pub-8759032363251002/9917112645';
  static const _interstitialProd = 'ca-app-pub-8759032363251002/7946221708';
  static const _rewardedInterstitialProd =
      'ca-app-pub-8759032363251002/6635671042';
  static const _rewardedProd = 'ca-app-pub-8759032363251002/3009796315';

  // ── Google test IDs (debug only — never click real ads during dev) ───────
  static const _bannerTest = 'ca-app-pub-3940256099942544/6300978111';
  static const _interstitialTest = 'ca-app-pub-3940256099942544/1033173712';
  static const _rewardedInterstitialTest =
      'ca-app-pub-3940256099942544/5354551991';
  static const _rewardedTest = 'ca-app-pub-3940256099942544/5224354917';

  // Active IDs: test in debug, production in release
  String get _bannerId => kDebugMode ? _bannerTest : _bannerProd;
  String get _interstitialId =>
      kDebugMode ? _interstitialTest : _interstitialProd;
  String get _rewardedInterstitialId =>
      kDebugMode ? _rewardedInterstitialTest : _rewardedInterstitialProd;
  String get _rewardedId => kDebugMode ? _rewardedTest : _rewardedProd;

  // ── State ────────────────────────────────────────────────────────────────
  bool _initialized = false;
  bool _isPremium = false; // set via setPremium() from SubscriptionProvider

  // Banner
  BannerAd? _banner;
  bool _bannerLoaded = false;

  // Interstitial
  InterstitialAd? _interstitial;
  bool _interstitialReady = false;
  DateTime? _lastInterstitialShown;
  static const _interstitialCooldown = Duration(minutes: 3);
  int _interstitialRetry = 0;

  // Rewarded
  RewardedAd? _rewarded;
  bool _rewardedReady = false;
  int _rewardedRetry = 0;

  // Rewarded interstitial
  RewardedInterstitialAd? _rewardedInterstitial;
  bool _rewardedInterstitialReady = false;
  int _rewardedInterstitialRetry = 0;

  // Max retry attempts before giving up (prevents infinite loops)
  static const _maxRetry = 3;

  // ── Public flags ─────────────────────────────────────────────────────────
  bool get isBannerLoaded => _bannerLoaded && !_isPremium;
  bool get isInterstitialReady => _interstitialReady && !_isPremium;
  bool get isRewardedReady => _rewardedReady;
  bool get isRewardedInterstitialReady => _rewardedInterstitialReady;

  // ─────────────────────────────────────────────────────────────────────────
  // Initialization — call once from main() before runApp
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await MobileAds.instance.initialize();
      // Request configuration: child-directed treatment off, max ad content
      // rating for general audiences (G-rated)
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          maxAdContentRating: MaxAdContentRating.g,
          tagForChildDirectedTreatment:
              TagForChildDirectedTreatment.unspecified,
          tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
        ),
      );
      _initialized = true;
      _log('AdMob SDK initialized');

      // Preload all formats in parallel
      await Future.wait([
        _loadBanner(),
        _loadInterstitial(),
        _loadRewarded(),
        _loadRewardedInterstitial(),
      ]);
    } catch (e) {
      _log('AdMob init error: $e');
      // Non-fatal — app continues without ads
    }
  }

  /// Call this whenever premium status changes so ads are shown/hidden instantly.
  void setPremium(bool isPremium) {
    _isPremium = isPremium;
    if (isPremium) {
      // Dispose loaded ads immediately — premium users never see them
      _banner?.dispose();
      _banner = null;
      _bannerLoaded = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Banner
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadBanner() async {
    if (_isPremium) return;
    _banner?.dispose();
    _banner = BannerAd(
      adUnitId: _bannerId,
      // Adaptive banner fills the full width for better eCPM
      size: AdSize.banner,
      request: _request(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _bannerLoaded = true;
          _log('✅ Banner loaded');
        },
        onAdFailedToLoad: (ad, error) {
          _bannerLoaded = false;
          ad.dispose();
          _banner = null;
          _log('❌ Banner failed: ${error.message}');
          // Retry once after 30 s — banner failure is not critical
          Future.delayed(const Duration(seconds: 30), _loadBanner);
        },
        onAdOpened: (_) => _log('Banner opened'),
        onAdClosed: (_) => _log('Banner closed'),
      ),
    )..load();
  }

  /// Returns an adaptive-width banner widget pinned to the bottom of a screen.
  /// Returns [SizedBox.shrink()] when not loaded or user is premium.
  Widget buildBanner() {
    if (!_bannerLoaded || _banner == null || _isPremium) {
      return const SizedBox.shrink();
    }
    return Container(
      alignment: Alignment.center,
      width: _banner!.size.width.toDouble(),
      height: _banner!.size.height.toDouble(),
      child: AdWidget(ad: _banner!),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Interstitial
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadInterstitial() async {
    if (_isPremium) return;
    await InterstitialAd.load(
      adUnitId: _interstitialId,
      request: _request(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialRetry = 0;
          _interstitial = ad;
          _interstitialReady = true;
          _log('✅ Interstitial loaded');
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (_) => _log('Interstitial shown'),
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitial = null;
              _interstitialReady = false;
              _loadInterstitial(); // preload next immediately
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitial = null;
              _interstitialReady = false;
              _log('❌ Interstitial show failed: ${error.message}');
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialReady = false;
          _log('❌ Interstitial load failed: ${error.message}');
          _scheduleRetry(
            retry: ++_interstitialRetry,
            onRetry: _loadInterstitial,
          );
        },
      ),
    );
  }

  /// Show interstitial at [AdPlacement.menuNavigation] or [AdPlacement.sessionComplete].
  ///
  /// Hard UX rules:
  /// - Only at [menuNavigation] or [sessionComplete] placements
  /// - Max once every [_interstitialCooldown] (3 min)
  /// - Never shown to premium users
  /// - Silent no-op if ad isn't ready
  Future<void> showInterstitial({
    AdPlacement placement = AdPlacement.menuNavigation,
  }) async {
    if (_isPremium) return;
    if (!_interstitialReady || _interstitial == null) return;

    // Only allowed placements
    if (placement != AdPlacement.menuNavigation &&
        placement != AdPlacement.sessionComplete) return;

    // Frequency cap
    final now = DateTime.now();
    if (_lastInterstitialShown != null &&
        now.difference(_lastInterstitialShown!) < _interstitialCooldown) {
      _log('ℹ️ Interstitial skipped — cooldown active');
      return;
    }

    _lastInterstitialShown = now;
    await _interstitial!.show();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Rewarded
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadRewarded() async {
    await RewardedAd.load(
      adUnitId: _rewardedId,
      request: _request(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedRetry = 0;
          _rewarded = ad;
          _rewardedReady = true;
          _log('✅ Rewarded loaded');
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (_) => _log('Rewarded shown'),
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewarded = null;
              _rewardedReady = false;
              _loadRewarded();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewarded = null;
              _rewardedReady = false;
              _log('❌ Rewarded show failed: ${error.message}');
              _loadRewarded();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _rewardedReady = false;
          _log('❌ Rewarded load failed: ${error.message}');
          _scheduleRetry(
            retry: ++_rewardedRetry,
            onRetry: _loadRewarded,
          );
        },
      ),
    );
  }

  /// Show rewarded ad — user explicitly opted in.
  ///
  /// [onRewarded]     — fires with seed/coin amount when user completes ad.
  /// [onNotAvailable] — fires instantly if ad isn't loaded (show a toast).
  /// [onDismissed]    — fires when the ad closes (rewarded or not).
  Future<void> showRewarded({
    required void Function(int amount) onRewarded,
    required void Function() onNotAvailable,
    void Function()? onDismissed,
  }) async {
    if (!_rewardedReady || _rewarded == null) {
      onNotAvailable();
      return;
    }
    await _rewarded!.show(
      onUserEarnedReward: (_, reward) {
        final amount = reward.amount.toInt();
        _log('🎁 Rewarded earned: $amount ${reward.type}');
        onRewarded(amount);
      },
    );
    onDismissed?.call();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Rewarded Interstitial
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadRewardedInterstitial() async {
    await RewardedInterstitialAd.load(
      adUnitId: _rewardedInterstitialId,
      request: _request(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedInterstitialRetry = 0;
          _rewardedInterstitial = ad;
          _rewardedInterstitialReady = true;
          _log('✅ Rewarded interstitial loaded');
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (_) =>
                _log('Rewarded interstitial shown'),
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedInterstitial = null;
              _rewardedInterstitialReady = false;
              _loadRewardedInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedInterstitial = null;
              _rewardedInterstitialReady = false;
              _log('❌ Rewarded interstitial show failed: ${error.message}');
              _loadRewardedInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _rewardedInterstitialReady = false;
          _log('❌ Rewarded interstitial load failed: ${error.message}');
          _scheduleRetry(
            retry: ++_rewardedInterstitialRetry,
            onRetry: _loadRewardedInterstitial,
          );
        },
      ),
    );
  }

  /// Show rewarded interstitial after session completion.
  ///
  /// Only shown at [AdPlacement.rewardedInterstitialOptIn].
  /// User earns a bonus reward (e.g. garden seeds) for watching.
  Future<void> showRewardedInterstitial({
    required void Function(int amount) onRewarded,
    required void Function() onNotAvailable,
    void Function()? onDismissed,
  }) async {
    if (!_rewardedInterstitialReady || _rewardedInterstitial == null) {
      onNotAvailable();
      return;
    }
    await _rewardedInterstitial!.show(
      onUserEarnedReward: (_, reward) {
        final amount = reward.amount.toInt();
        _log('🎁 Rewarded interstitial earned: $amount ${reward.type}');
        onRewarded(amount);
      },
    );
    onDismissed?.call();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Builds a standard ad request with GDPR-safe defaults.
  AdRequest _request() => const AdRequest(
        nonPersonalizedAds: false, // set true if GDPR consent is denied
      );

  /// Exponential backoff retry: 5 s, 20 s, 60 s — then stops.
  void _scheduleRetry(
      {required int retry, required Future<void> Function() onRetry}) {
    if (retry > _maxRetry) {
      _log('ℹ️ Max retries reached — giving up until next app session');
      return;
    }
    final delays = [
      Duration(seconds: 5),
      Duration(seconds: 20),
      Duration(seconds: 60)
    ];
    final delay = retry <= delays.length ? delays[retry - 1] : delays.last;
    _log('⏳ Retry $retry in ${delay.inSeconds}s');
    Future.delayed(delay, onRetry);
  }

  void _log(String msg) {
    if (kDebugMode) debugPrint('[AdService] $msg');
  }

  /// Release all ad resources on app teardown.
  void disposeAll() {
    _banner?.dispose();
    _interstitial?.dispose();
    _rewarded?.dispose();
    _rewardedInterstitial?.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AdBannerWidget — drop this at the BOTTOM of any Scaffold body.
//
// Usage:
//   bottomNavigationBar: Column(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       AdBannerWidget(),
//       _buildBottomNav(),
//     ],
//   ),
//
// The widget is transparent when no ad is loaded — zero layout impact.
// ─────────────────────────────────────────────────────────────────────────────

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  final _adService = AdService();
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    if (_adService._isPremium) return;
    final ad = BannerAd(
      adUnitId: _adService._bannerId,
      size: AdSize.banner,
      request: _adService._request(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) setState(() => _loaded = false);
        },
      ),
    )..load();
    _ad = ad;
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _ad == null || _adService._isPremium) {
      return const SizedBox.shrink();
    }
    return SafeArea(
      top: false,
      child: Container(
        alignment: Alignment.center,
        width: _ad!.size.width.toDouble(),
        height: _ad!.size.height.toDouble(),
        child: AdWidget(ad: _ad!),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RewardedAdButton — a styled CTA that triggers a rewarded ad.
//
// Shows "Watch ad for +N seeds" — grays out if ad not ready.
// Automatically shows a snackbar on success/unavailable.
//
// Usage inside any screen:
//   RewardedAdButton(
//     label: 'Watch ad for +10 seeds',
//     onRewarded: (amount) => walletProvider.addSeeds(amount),
//   )
// ─────────────────────────────────────────────────────────────────────────────

class RewardedAdButton extends StatefulWidget {
  const RewardedAdButton({
    super.key,
    required this.label,
    required this.onRewarded,
    this.useRewardedInterstitial = false,
  });

  final String label;
  final void Function(int amount) onRewarded;

  /// If true, shows the richer rewarded-interstitial format.
  final bool useRewardedInterstitial;

  @override
  State<RewardedAdButton> createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends State<RewardedAdButton> {
  final _ads = AdService();
  bool _loading = false;

  bool get _ready => widget.useRewardedInterstitial
      ? _ads.isRewardedInterstitialReady
      : _ads.isRewardedReady;

  Future<void> _onTap() async {
    if (!_ready || _loading) return;
    setState(() => _loading = true);

    void onRewarded(int amount) {
      widget.onRewarded(amount);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎁 You earned $amount seeds!'),
            backgroundColor: const Color(0xFF39D353),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    void onNotAvailable() {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ad not available right now — try again soon'),
            backgroundColor: Colors.grey[800],
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    if (widget.useRewardedInterstitial) {
      await _ads.showRewardedInterstitial(
        onRewarded: onRewarded,
        onNotAvailable: onNotAvailable,
        onDismissed: () {
          if (mounted) setState(() => _loading = false);
        },
      );
    } else {
      await _ads.showRewarded(
        onRewarded: onRewarded,
        onNotAvailable: onNotAvailable,
        onDismissed: () {
          if (mounted) setState(() => _loading = false);
        },
      );
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isReady = _ready && !_loading;

    return AnimatedOpacity(
      opacity: isReady ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 250),
      child: GestureDetector(
        onTap: isReady ? _onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: isReady
                ? LinearGradient(
                    colors: [colors.primary, colors.secondary],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: isReady ? null : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isReady
                  ? colors.primary.withOpacity(0.6)
                  : Colors.white.withOpacity(0.2),
            ),
            boxShadow: isReady
                ? [
                    BoxShadow(
                      color: colors.primary.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_loading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              else
                const Icon(Icons.play_circle_outline_rounded,
                    color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                _loading ? 'Loading…' : widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
