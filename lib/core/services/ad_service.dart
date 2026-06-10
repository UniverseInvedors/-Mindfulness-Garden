import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // ── Real Ad Unit IDs ──────────────────────────────────────────────
  static const String _bannerIdProd = 'ca-app-pub-8436172731596367/1842302530';
  static const String _interstitialIdProd =
      'ca-app-pub-8436172731596367/9529220864';
  static const String _rewardedIdProd =
      'ca-app-pub-8436172731596367/7072098393';

  // Google test IDs (used in debug builds so you never click real ads)
  static const String _bannerIdTest = 'ca-app-pub-3940256099942544/6300978111';
  static const String _interstitialIdTest =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _rewardedIdTest =
      'ca-app-pub-3940256099942544/5224354917';

  String get _bannerId => kDebugMode ? _bannerIdTest : _bannerIdProd;
  String get _interstitialId =>
      kDebugMode ? _interstitialIdTest : _interstitialIdProd;
  String get _rewardedId => kDebugMode ? _rewardedIdTest : _rewardedIdProd;
  // ─────────────────────────────────────────────────────────────────

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isInitialized = false;
  bool _bannerLoaded = false;
  bool _interstitialReady = false;
  bool _rewardedReady = false;

  bool get isBannerLoaded => _bannerLoaded;
  bool get isInterstitialReady => _interstitialReady;
  bool get isRewardedReady => _rewardedReady;

  // ── Init ─────────────────────────────────────────────────────────
  Future<void> initialize() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();
    _isInitialized = true;
    _loadBanner();
    _loadInterstitial();
    _loadRewarded();
  }

  // ── Banner ───────────────────────────────────────────────────────
  void _loadBanner() {
    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: _bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _bannerLoaded = true;
          debugPrint('✅ Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          _bannerLoaded = false;
          ad.dispose();
          debugPrint('❌ Banner ad failed: $error');
        },
      ),
    )..load();
  }

  /// Returns a banner widget — call inside a Column/Stack at screen bottom.
  Widget buildBanner() {
    if (!_bannerLoaded || _bannerAd == null) return const SizedBox.shrink();
    return SafeArea(
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }

  // ── Interstitial ─────────────────────────────────────────────────
  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialReady = true;
          debugPrint('✅ Interstitial ad loaded');
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialReady = false;
              _loadInterstitial(); // preload next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialReady = false;
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialReady = false;
          debugPrint('❌ Interstitial ad failed: $error');
        },
      ),
    );
  }

  /// Show interstitial — e.g. between sessions or on screen exit.
  Future<void> showInterstitial() async {
    if (_interstitialReady && _interstitialAd != null) {
      await _interstitialAd!.show();
    } else {
      debugPrint('ℹ️ Interstitial not ready yet');
    }
  }

  // ── Rewarded ─────────────────────────────────────────────────────
  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: _rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedReady = true;
          debugPrint('✅ Rewarded ad loaded');
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedReady = false;
              _loadRewarded(); // preload next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedReady = false;
              _loadRewarded();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _rewardedReady = false;
          debugPrint('❌ Rewarded ad failed: $error');
        },
      ),
    );
  }

  /// Show rewarded ad — e.g. "Watch ad for coins/seeds".
  /// [onRewarded] fires with the reward amount when user completes the ad.
  /// [onNotAvailable] fires if ad isn't loaded yet.
  Future<void> showRewarded({
    required void Function(int amount) onRewarded,
    required void Function() onNotAvailable,
  }) async {
    if (_rewardedReady && _rewardedAd != null) {
      await _rewardedAd!.show(
        onUserEarnedReward: (_, reward) {
          onRewarded(reward.amount.toInt());
        },
      );
    } else {
      onNotAvailable();
    }
  }

  // ── Cleanup ───────────────────────────────────────────────────────
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
