// ignore_for_file: deprecated_member_use
//
// subscription_screen.dart
// AAA-quality Premium paywall — Mindfulness Garden
//
// • Material 3 + glassmorphism cards
// • Nature-inspired green/blue gradient background
// • Animated floating leaves (CustomPainter, no extra deps)
// • Smooth fade + slide entry animations
// • Dark mode and light mode support via Theme.of(context)
// • Riverpod-compatible (reads SubscriptionProvider via provider package)
// • Placeholder callbacks: onContinue(productId), onRestorePurchases()
// • Product IDs: mindfulness_premium_monthly / mindfulness_premium_yearly
// • No billing logic — UI only

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pranaverse/presentation/providers/subscription_provider.dart';

// ────────────────────────────────────────────────────────────────────────────
// Data models
// ────────────────────────────────────────────────────────────────────────────

/// A single subscription plan shown in the plan selector.
class _Plan {
  const _Plan({
    required this.productId,
    required this.title,
    required this.price,
    required this.period,
    required this.description,
    this.badge,
    this.savings,
  });

  final String productId;
  final String title;
  final String price;
  final String period;
  final String description;
  final String? badge;
  final String? savings;
}

/// A single premium feature row.
class _Feat {
  const _Feat(this.icon, this.title, this.subtitle, this.color);
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
}

/// A floating leaf particle.
class _Leaf {
  _Leaf(this.x, this.y, this.size, this.opacity, this.speed, this.drift,
      this.glyph);
  double x, y, size, opacity, speed, drift;
  final String glyph;
}

// ────────────────────────────────────────────────────────────────────────────
// SubscriptionScreen
// ────────────────────────────────────────────────────────────────────────────

/// AAA-quality premium paywall for Mindfulness Garden.
///
/// [onContinue]         — called with the selected product-id when user taps
///                        "Continue". Pass `null` to use the built-in stub.
/// [onRestorePurchases] — called when user taps "Restore Purchases".
///                        Pass `null` to use the built-in stub.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({
    super.key,
    this.onContinue,
    this.onRestorePurchases,
  });

  final void Function(String productId)? onContinue;
  final VoidCallback? onRestorePurchases;

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with TickerProviderStateMixin {
  // ── Static data ────────────────────────────────────────────────────────────

  static const _plans = [
    _Plan(
      productId: 'mindfulness_premium_monthly',
      title: 'Monthly Premium',
      price: '₹199',
      period: '/month',
      description: 'Auto-renewing subscription',
    ),
    _Plan(
      productId: 'mindfulness_premium_yearly',
      title: 'Yearly Premium',
      price: '₹1,499',
      period: '/year',
      description: 'Best value — billed annually',
      badge: 'Best Value',
      savings: 'Save 37%',
    ),
  ];

  static const _features = [
    _Feat(Icons.self_improvement_rounded, 'Unlimited Guided Meditations',
        '500+ sessions for every mood & goal', Color(0xFF9D4EDD)),
    _Feat(Icons.air_rounded, 'Unlimited Breathing Exercises',
        'All 6 science-backed techniques', Color(0xFF00B4D8)),
    _Feat(Icons.psychology_rounded, 'AI Meditation Coach',
        'Personalised Zeno guidance every day', Color(0xFFFF6BF5)),
    _Feat(Icons.spa_rounded, 'Exclusive Garden Themes',
        '20+ rare immersive environments', Color(0xFF39D353)),
    _Feat(Icons.local_florist_rounded, 'Grow Your Garden Faster',
        '3× growth multiplier on all actions', Color(0xFF70E000)),
    _Feat(Icons.bedtime_rounded, 'Advanced Sleep Programs',
        'Yoga Nidra, Delta waves & sleep hygiene', Color(0xFF4D6EFF)),
    _Feat(Icons.insights_rounded, 'Mood & Progress Analytics',
        'Deep trends, streaks & health map', Color(0xFFFFE566)),
    _Feat(Icons.block_rounded, 'No Advertisements',
        'Uninterrupted peace — always', Color(0xFFFF8500)),
    _Feat(Icons.support_agent_rounded, 'Priority Support',
        'Direct access to our wellness team', Color(0xFF48CAE4)),
    _Feat(Icons.rocket_launch_rounded, 'Early Access to New Features',
        'First to try every new release', Color(0xFFAA44FF)),
  ];

  // ── State ──────────────────────────────────────────────────────────────────
  int _selectedIndex = 1; // yearly pre-selected (best value)
  bool _busy = false;

  // ── Animation controllers ──────────────────────────────────────────────────
  late final AnimationController _entryCtrl;
  late final AnimationController _leafCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // Floating leaves
  final _rng = math.Random(7);
  late final List<_Leaf> _leaves;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 750))
      ..forward();
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _leafCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 9))
          ..repeat();

    _pulseCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    const glyphs = ['🍃', '🌿', '🍀', '🌱', '🌾'];
    _leaves = List.generate(
        16,
        (i) => _Leaf(
              _rng.nextDouble(),
              _rng.nextDouble(),
              12 + _rng.nextDouble() * 16,
              0.20 + _rng.nextDouble() * 0.40,
              0.03 + _rng.nextDouble() * 0.07,
              (_rng.nextDouble() - 0.5) * 0.04,
              glyphs[i % glyphs.length],
            ));
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _leafCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _onContinue() async {
    HapticFeedback.mediumImpact();
    final id = _plans[_selectedIndex].productId;

    if (widget.onContinue != null) {
      widget.onContinue!(id);
      return;
    }

    // Built-in stub: brief loading then mark subscribed
    setState(() => _busy = true);
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    setState(() => _busy = false);
    if (context.mounted) {
      context.read<SubscriptionProvider>().updateSubscriptionStatus(true);
      _showMsg(
        '🎉 Welcome to Premium!',
        'All features unlocked. Your transformation starts right now.',
      );
    }
  }

  void _onRestore() {
    HapticFeedback.selectionClick();
    if (widget.onRestorePurchases != null) {
      widget.onRestorePurchases!();
      return;
    }
    _showMsg(
      'Restore Purchases',
      'Your previous purchases have been checked.\n'
          'Contact support@mindfulgarden.app if you need help.',
    );
  }

  void _showMsg(String title, String body) {
    showDialog(
      context: context,
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0D2318) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(title,
              style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF061410),
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
          content: Text(body,
              style: TextStyle(
                  color:
                      (isDark ? Colors.white : Colors.black).withOpacity(0.65),
                  height: 1.55,
                  fontSize: 14)),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF39D353),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Got it!',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  // ── Root build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF061410) : const Color(0xFFEEFBF3),
        body: Stack(
          children: [
            // ── 1. Gradient background ─────────────────────────────────
            _Background(isDark: isDark),

            // ── 2. Floating leaf particles ─────────────────────────────
            _LeafLayer(ctrl: _leafCtrl, leaves: _leaves),

            // ── 3. Scrollable content ──────────────────────────────────
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader(isDark)),
                      SliverToBoxAdapter(child: _buildFeatureSection(isDark)),
                      SliverToBoxAdapter(child: _buildPlanSection(isDark)),
                      SliverToBoxAdapter(child: _buildCTA(isDark)),
                      SliverToBoxAdapter(child: _buildFooter(isDark)),
                      const SliverToBoxAdapter(child: SizedBox(height: 40)),
                    ],
                  ),
                ),
              ),
            ),

            // ── 4. Close button (always on top) ────────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 18,
              child: _CircleBtn(
                icon: Icons.close_rounded,
                isDark: isDark,
                onTap: () =>
                    context.canPop() ? context.pop() : context.go('/main'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(bool isDark) {
    final txt = isDark ? Colors.white : const Color(0xFF061410);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 4),
      child: Column(
        children: [
          // Pulsing animated crown icon
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, child) => Transform.scale(
              scale: 1.0 + _pulseCtrl.value * 0.055,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFAA44FF), Color(0xFF39D353)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFAA44FF)
                          .withOpacity(0.30 + _pulseCtrl.value * 0.22),
                      blurRadius: 32,
                      spreadRadius: 4,
                    ),
                    BoxShadow(
                      color: const Color(0xFF39D353)
                          .withOpacity(0.18 + _pulseCtrl.value * 0.14),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    color: Colors.white, size: 54),
              ),
            ),
          ),
          const SizedBox(height: 22),
          // Title
          Text(
            'Unlock Mindfulness Garden\nPremium',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: txt,
              fontSize: 27,
              fontWeight: FontWeight.w900,
              height: 1.18,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          // Subtitle
          Text(
            'Transform your wellness journey with unlimited access.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: txt.withOpacity(0.62),
              fontSize: 15,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ── Feature section ────────────────────────────────────────────────────────

  Widget _buildFeatureSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(text: 'EVERYTHING YOU GET', isDark: isDark),
          const SizedBox(height: 12),
          _Glass(
            isDark: isDark,
            child: Column(
              children: List.generate(_features.length, (i) {
                final f = _features[i];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FeatureTile(feat: f, isDark: isDark),
                    if (i < _features.length - 1)
                      Divider(
                        height: 1,
                        color: (isDark ? Colors.white : Colors.black)
                            .withOpacity(0.07),
                        indent: 60,
                        endIndent: 16,
                      ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  // ── Plan section ───────────────────────────────────────────────────────────

  Widget _buildPlanSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(text: 'CHOOSE YOUR PLAN', isDark: isDark),
          const SizedBox(height: 12),
          ...List.generate(
              _plans.length,
              (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _PlanCard(
                      plan: _plans[i],
                      selected: _selectedIndex == i,
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedIndex = i);
                      },
                    ),
                  )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── CTA ────────────────────────────────────────────────────────────────────

  Widget _buildCTA(bool isDark) {
    final dimTxt = isDark
        ? Colors.white.withOpacity(0.55)
        : const Color(0xFF1A6B3C).withOpacity(0.75);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        children: [
          // Continue button
          SizedBox(
            width: double.infinity,
            height: 58,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF39D353), Color(0xFF00B4D8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF39D353).withOpacity(0.38),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: _busy ? null : _onContinue,
                  child: Center(
                    child: _busy
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Restore purchases
          GestureDetector(
            onTap: _onRestore,
            child: Text(
              'Restore Purchases',
              style: TextStyle(
                color: dimTxt,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: dimTxt,
              ),
            ),
          ),
          const SizedBox(height: 26),
        ],
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────

  Widget _buildFooter(bool isDark) {
    final dim = (isDark ? Colors.white : Colors.black).withOpacity(0.42);
    final link = isDark ? const Color(0xFF48CAE4) : const Color(0xFF1A6B3C);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Terms + Privacy
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(color: dim, fontSize: 12, height: 1.65),
              children: [
                const TextSpan(text: 'By continuing you agree to the '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Terms of Service',
                      style: TextStyle(
                        color: link,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: link,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: ' and '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: link,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: link,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Auto-renew notice
          Text(
            'Subscription automatically renews unless cancelled at least '
            '24 hours before the renewal date. Manage or cancel anytime '
            'in your Google Play account settings.',
            textAlign: TextAlign.center,
            style: TextStyle(color: dim, fontSize: 11, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// _Background — full-screen nature gradient
// ────────────────────────────────────────────────────────────────────────────

class _Background extends StatelessWidget {
  const _Background({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF061410),
                    Color(0xFF0D2318),
                    Color(0xFF03052A),
                    Color(0xFF0C0015),
                  ]
                : const [
                    Color(0xFFEEFBF3),
                    Color(0xFFD4F5E2),
                    Color(0xFFCCEEFF),
                    Color(0xFFEFE8FF),
                  ],
            stops: const [0.0, 0.35, 0.7, 1.0],
          ),
        ),
      );
}

// ────────────────────────────────────────────────────────────────────────────
// _LeafLayer — animated floating leaf particles
// ────────────────────────────────────────────────────────────────────────────

class _LeafLayer extends StatelessWidget {
  const _LeafLayer({required this.ctrl, required this.leaves});
  final AnimationController ctrl;
  final List<_Leaf> leaves;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: ctrl,
        builder: (_, __) => IgnorePointer(
          child: CustomPaint(
            painter: _LeafPainter(ctrl.value, leaves),
            size: Size.infinite,
          ),
        ),
      );
}

class _LeafPainter extends CustomPainter {
  _LeafPainter(this.t, this.leaves);
  final double t;
  final List<_Leaf> leaves;

  @override
  void paint(Canvas canvas, Size size) {
    for (final leaf in leaves) {
      final y = (leaf.y - t * leaf.speed) % 1.0;
      final x = leaf.x + math.sin(t * math.pi * 2 + leaf.y * 5) * leaf.drift;
      final tp = TextPainter(
        text: TextSpan(
          text: leaf.glyph,
          style: TextStyle(
            fontSize: leaf.size,
            color: Colors.white.withOpacity(leaf.opacity),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x * size.width, y * size.height));
    }
  }

  @override
  bool shouldRepaint(_LeafPainter old) => old.t != t;
}

// ────────────────────────────────────────────────────────────────────────────
// _Glass — glassmorphism card container
// ────────────────────────────────────────────────────────────────────────────

class _Glass extends StatelessWidget {
  const _Glass({required this.child, required this.isDark});
  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.white.withOpacity(0.74),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.13)
                  : Colors.white.withOpacity(0.92),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.22 : 0.07),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      );
}

// ────────────────────────────────────────────────────────────────────────────
// _CircleBtn — close / back glass circle button
// ────────────────────────────────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  const _CircleBtn(
      {required this.icon, required this.isDark, required this.onTap});
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.13)
                : Colors.white.withOpacity(0.78),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.22)
                  : Colors.black.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 10),
            ],
          ),
          child: Icon(icon,
              color: isDark ? Colors.white : const Color(0xFF061410), size: 20),
        ),
      );
}

// ────────────────────────────────────────────────────────────────────────────
// _Label — section heading
// ────────────────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label({required this.text, required this.isDark});
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          color: isDark ? const Color(0xFF39D353) : const Color(0xFF1A6B3C),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.0,
        ),
      );
}

// ────────────────────────────────────────────────────────────────────────────
// _FeatureTile — one row inside the features glass card
// ────────────────────────────────────────────────────────────────────────────

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feat, required this.isDark});
  final _Feat feat;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final txt = isDark ? Colors.white : const Color(0xFF061410);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      child: Row(
        children: [
          // Icon badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: feat.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(feat.icon, color: feat.color, size: 21),
          ),
          const SizedBox(width: 14),
          // Text
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(feat.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: txt, fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(feat.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(color: txt.withOpacity(0.50), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Check
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF39D353), size: 20),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// _PlanCard — subscription plan selector card
// ────────────────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final _Plan plan;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final txt = isDark ? Colors.white : const Color(0xFF061410);
    final subtle = txt.withOpacity(0.50);
    final border = selected
        ? const Color(0xFF39D353)
        : (isDark
            ? Colors.white.withOpacity(0.15)
            : Colors.black.withOpacity(0.10));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 230),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF39D353).withOpacity(isDark ? 0.12 : 0.07)
              : (isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.white.withOpacity(0.72)),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border, width: selected ? 2.2 : 1.2),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF39D353).withOpacity(0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Badge bar ─────────────────────────────────────────────
            if (plan.badge != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF39D353), Color(0xFF00B4D8)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 5),
                    Text(plan.badge!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 0.8)),
                    if (plan.savings != null) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(plan.savings!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11)),
                      ),
                    ],
                  ],
                ),
              ),

            // ── Card body ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Radio indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? const Color(0xFF39D353)
                          : Colors.transparent,
                      border: Border.all(
                        color: selected ? const Color(0xFF39D353) : subtle,
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 14)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  // Name + description
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: txt,
                                fontWeight: FontWeight.w800,
                                fontSize: 15)),
                        const SizedBox(height: 3),
                        Text(plan.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: subtle, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Price
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(plan.price,
                          style: TextStyle(
                              color: selected ? const Color(0xFF39D353) : txt,
                              fontSize: 22,
                              fontWeight: FontWeight.w900)),
                      Text(plan.period,
                          style: TextStyle(color: subtle, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
