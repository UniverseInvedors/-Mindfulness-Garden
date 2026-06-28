// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WelcomeScreen — shown once after a successful login or sign-up.
//
// Explains how the app helps users stay active via meditation and yoga, then
// takes them to the main menu.
// ─────────────────────────────────────────────────────────────────────────────

class WelcomeScreen extends StatefulWidget {
  /// Pass the user's first name (or null for a generic greeting).
  final String? userName;

  const WelcomeScreen({super.key, this.userName});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  int _featureIndex = 0;
  late final PageController _pageCtrl = PageController();

  static const _features = [
    _Feature(
      emoji: '🧘',
      title: 'Daily Meditations',
      body:
          'Start or end every day with a guided session led by Zeno, your AI wellness companion. '
          'Even 5 minutes of mindful breathing reshapes your stress response over time.',
      color: Color(0xFF9d4edd),
    ),
    _Feature(
      emoji: '🏯',
      title: 'Immersive Yoga',
      body:
          'Practice yoga inside a living 2.5D scene that reacts to your poses and breathing. '
          'Flows are tailored to your energy level, so you always move at the right pace.',
      color: Color(0xFFe9c46a),
    ),
    _Feature(
      emoji: '🌿',
      title: 'Living Garden',
      body: 'Your consistency grows a real-time mindfulness garden. '
          'Meditate, breathe, or log your mood — every action plants a seed and fuels your sanctuary.',
      color: Color(0xFF38b000),
    ),
    _Feature(
      emoji: '📈',
      title: 'Streak & Progress',
      body: 'Streaks, mood charts, and achievement badges keep you motivated. '
          'See exactly how many calm minutes you have banked and watch your well-being climb.',
      color: Color(0xFF00b4d8),
    ),
    _Feature(
      emoji: '🌬️',
      title: 'Breathing Studio',
      body:
          'Six science-backed techniques — from Box Breathing to the 4-7-8 method — '
          'help you reset in real time, whether you face stress, anxiety, or sleeplessness.',
      color: Color(0xFFf72585),
    ),
  ];

  void _next() {
    if (_featureIndex < _features.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/main');
    }
  }

  void _skip() => context.go('/main');

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          // ── Animated gradient background ────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.surface,
                  _features[_featureIndex].color.withOpacity(0.18),
                  colors.surface,
                ],
              ),
            ),
          ),

          // ── Decorative blobs ────────────────────────────────────────────
          Positioned(
            top: -80,
            right: -60,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _features[_featureIndex].color.withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -40,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _features[_featureIndex].color.withOpacity(0.08),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      // Page dots
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          _features.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 6),
                            width: i == _featureIndex ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: i == _featureIndex
                                  ? _features[_featureIndex].color
                                  : Colors.white.withOpacity(0.25),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _skip,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Welcome heading (shown only on first page) ────────────
                if (_featureIndex == 0) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userName != null
                              ? 'Welcome, ${widget.userName}! 🌱'
                              : 'Welcome to Mindfulness Garden 🌱',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.3, end: 0),
                        const SizedBox(height: 10),
                        Text(
                          'Your personal space to stay active, calm, and in balance — '
                          'one breath, one pose, one session at a time.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.72),
                            fontSize: 15,
                            height: 1.55,
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Feature carousel ─────────────────────────────────────
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    itemCount: _features.length,
                    onPageChanged: (i) => setState(() => _featureIndex = i),
                    itemBuilder: (_, i) => _FeatureCard(
                      feature: _features[i],
                      isActive: i == _featureIndex,
                    ),
                  ),
                ),

                // ── CTA button ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
                  child: SizedBox(
                    width: double.infinity,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: [
                            _features[_featureIndex].color,
                            _features[_featureIndex].color.withOpacity(0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                _features[_featureIndex].color.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: _next,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _featureIndex < _features.length - 1
                                      ? 'Next'
                                      : 'Begin My Journey',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Feature card widget
// ─────────────────────────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature, required this.isActive});
  final _Feature feature;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji icon
          AnimatedScale(
            scale: isActive ? 1.0 : 0.88,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: feature.color.withOpacity(0.18),
                border: Border.all(
                  color: feature.color.withOpacity(0.35),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: feature.color.withOpacity(0.25),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  feature.emoji,
                  style: const TextStyle(fontSize: 52),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Title
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
            child: Text(feature.title, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),

          // Body
          Text(
            feature.body,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data class
// ─────────────────────────────────────────────────────────────────────────────

class _Feature {
  const _Feature({
    required this.emoji,
    required this.title,
    required this.body,
    required this.color,
  });
  final String emoji;
  final String title;
  final String body;
  final Color color;
}
