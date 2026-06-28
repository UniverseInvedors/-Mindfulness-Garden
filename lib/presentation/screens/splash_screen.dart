// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:pranaverse/presentation/providers/auth_provider.dart';
import 'package:pranaverse/presentation/providers/user_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PRANVERSE  –  Immersive Garden Splash Screen
// Design: deep night-garden with aurora glows, breathing orbs, rising fireflies,
//         swaying lotus petals and the PRANVERSE wordmark emerging from mist.
// ─────────────────────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────────────
  late AnimationController _breatheCtrl; // slow in-out for main orb
  late AnimationController _auroraCtrl; // aurora colour shift
  late AnimationController _particleCtrl; // fireflies / pollen rising
  late AnimationController _revealCtrl; // title + tagline entrance
  late AnimationController _petalCtrl; // lotus petal sway
  late AnimationController _progressCtrl; // loading bar

  // ── Derived animations ────────────────────────────────────────────────────
  late Animation<double> _breatheScale;
  late Animation<double> _breatheOpacity;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _taglineFade;
  // ── Loading state ─────────────────────────────────────────────────────────
  bool _disposed = false;
  bool _isInitialized = false;
  bool _showTagline = false;
  String _loadingMessage = 'Awakening the garden…';
  int _loadingProgress = 0;
  Timer? _progressTimer;
  Timer? _messageTimer;

  static const _messages = [
    'Planting seeds of stillness…',
    'Weaving moonlight into leaves…',
    'Calling the fireflies home…',
    'Breathing life into petals…',
    'PRANVERSE is ready…',
  ];

  // ── Firefly / particle data ───────────────────────────────────────────────
  late final List<_Particle> _particles;
  final _rng = math.Random(42);

  @override
  void initState() {
    super.initState();

    // Breathing controller – 4 s cycle, loops forever
    _breatheCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    _breatheScale = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut),
    );
    _breatheOpacity = Tween<double>(begin: 0.55, end: 0.85).animate(
      CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut),
    );

    // Aurora colour shift – 6 s cycle
    _auroraCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat(reverse: true);

    // Particles – 5 s cycle, loops
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();

    // Petal sway – 3 s cycle
    _petalCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // Reveal (title) – 2.5 s, plays once
    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _revealCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealCtrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // Progress bar controller – driven manually, shown via AnimatedBuilder
    _progressCtrl = AnimationController(vsync: this);

    // Generate particles
    _particles = List.generate(
      28,
      (i) => _Particle(
        x: _rng.nextDouble(),
        baseY: _rng.nextDouble(),
        size: 2.5 + _rng.nextDouble() * 4.5,
        speed: 0.4 + _rng.nextDouble() * 0.6,
        phase: _rng.nextDouble(),
        hue: 80 + _rng.nextDouble() * 120, // green to cyan range
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed && mounted) {
        setState(() => _isInitialized = true);
        _revealCtrl.forward();
        _startLoadingSequence();
        _startProgressTimer();
        _initializeApp().timeout(
          const Duration(seconds: 6),
          onTimeout: () {
            if (!_disposed && mounted) _navigateToNextScreen();
          },
        );
      }
    });
  }

  // ── Loading helpers ───────────────────────────────────────────────────────
  void _startLoadingSequence() {
    int idx = 0;
    _messageTimer = Timer.periodic(const Duration(milliseconds: 1400), (t) {
      if (idx < _messages.length && !_disposed && mounted) {
        setState(() => _loadingMessage = _messages[idx++]);
      } else {
        t.cancel();
      }
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!_disposed && mounted) setState(() => _showTagline = true);
    });
  }

  void _startProgressTimer() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 55), (t) {
      if (_loadingProgress < 90 && !_disposed && mounted) {
        setState(() {
          _loadingProgress = (_loadingProgress + 2).clamp(0, 90);
          _progressCtrl.value = _loadingProgress / 100;
        });
      } else {
        t.cancel();
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1200));
      await _loadUserData();
      if (!_disposed && mounted) {
        setState(() {
          _loadingProgress = 100;
          _loadingMessage = 'PRANVERSE is ready…';
        });
        _progressCtrl.value = 1.0;
      }
      await Future.delayed(const Duration(milliseconds: 400));
      _navigateToNextScreen();
    } catch (e) {
      _handleError(e);
    } finally {
      _progressTimer?.cancel();
      _messageTimer?.cancel();
    }
  }

  Future<void> _loadUserData() async {
    if (!mounted || _disposed) return;
    try {
      await context.read<UserProvider>().loadUser();
    } catch (_) {
      try {
        await context.read<UserProvider>().createDefaultUser();
      } catch (_) {}
    }
  }

  void _navigateToNextScreen() {
    if (!_disposed && mounted) {
      final auth = context.read<AuthProvider>();
      context.go(auth.currentUserId == null ? '/auth' : '/main');
    }
  }

  void _handleError(dynamic error) {
    if (kDebugMode) debugPrint('Splash error: $error');
    if (!_disposed && mounted) {
      setState(() => _loadingMessage = 'Something stirred in the garden…');
    }
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && !_disposed) _showErrorDialog();
    });
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => _ErrorDialog(
        onRetry: () {
          Navigator.of(context).pop();
          setState(() {
            _loadingProgress = 0;
            _progressCtrl.value = 0;
          });
          _startProgressTimer();
          _initializeApp();
        },
        onContinue: () {
          Navigator.of(context).pop();
          if (!_disposed && mounted) context.go('/main');
        },
      ),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _breatheCtrl.dispose();
    _auroraCtrl.dispose();
    _particleCtrl.dispose();
    _revealCtrl.dispose();
    _petalCtrl.dispose();
    _progressCtrl.dispose();
    _progressTimer?.cancel();
    _messageTimer?.cancel();
    super.dispose();
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF050D14),
        body: SizedBox.expand(),
      );
    }

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF050D14),
      body: Stack(
        children: [
          // ── Layer 1: Deep night-sky gradient ─────────────────────────────
          Positioned.fill(child: _NightSkyBackground(ctrl: _auroraCtrl)),

          // ── Layer 2: Aurora glow blobs ───────────────────────────────────
          Positioned.fill(child: _AuroraLayer(ctrl: _auroraCtrl, size: size)),

          // ── Layer 3: Garden silhouette (painted) ─────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _breatheCtrl,
              builder: (_, __) => CustomPaint(
                size: Size(size.width, size.height * 0.42),
                painter: _GardenPainter(progress: _breatheCtrl.value),
              ),
            ),
          ),

          // ── Layer 4: Rising fireflies / pollen ───────────────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, __) => CustomPaint(
                painter: _ParticlePainter(
                  particles: _particles,
                  progress: _particleCtrl.value,
                  size: size,
                ),
              ),
            ),
          ),

          // ── Layer 5: Central breathing orb ───────────────────────────────
          Center(
            child: _BreathingOrb(
              scaleAnim: _breatheScale,
              opacityAnim: _breatheOpacity,
            ),
          ),

          // ── Layer 6: PRANVERSE wordmark ───────────────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _revealCtrl,
              builder: (_, __) => Opacity(
                opacity: _titleFade.value,
                child: SlideTransition(
                  position: _titleSlide,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Main title
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFB8FFD6),
                            Color(0xFF7DFFCE),
                            Color(0xFF38FFB3),
                            Color(0xFF00E5A0),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          'PRANVERSE',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 10,
                            height: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Decorative divider
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _AuraDivider(ctrl: _breatheCtrl),
                          const SizedBox(width: 10),
                          const Icon(Icons.spa,
                              color: Color(0xFF7DFFCE), size: 18),
                          const SizedBox(width: 10),
                          _AuraDivider(ctrl: _breatheCtrl),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Tagline
                      Opacity(
                        opacity: _showTagline ? _taglineFade.value : 0.0,
                        child: const Text(
                          'B R E A T H E  ·  G R O W  ·  T R A N S C E N D',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF9EE8C8),
                            letterSpacing: 3.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Layer 7: Floating lotus petals ───────────────────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _petalCtrl,
              builder: (_, __) => CustomPaint(
                painter: _PetalPainter(
                  sway: _petalCtrl.value,
                  size: size,
                ),
              ),
            ),
          ),

          // ── Layer 8: Bottom loading panel ─────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _LoadingPanel(
              message: _loadingMessage,
              progress: _loadingProgress / 100,
              progressCtrl: _progressCtrl,
              isComplete: _loadingProgress >= 100,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NIGHT SKY BACKGROUND
// ─────────────────────────────────────────────────────────────────────────────
class _NightSkyBackground extends StatelessWidget {
  final AnimationController ctrl;
  const _NightSkyBackground({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(
                const Color(0xFF020810),
                const Color(0xFF040E1C),
                ctrl.value,
              )!,
              Color.lerp(
                const Color(0xFF061220),
                const Color(0xFF082040),
                ctrl.value,
              )!,
              Color.lerp(
                const Color(0xFF0A2010),
                const Color(0xFF0D2E18),
                ctrl.value,
              )!,
              const Color(0xFF041008),
            ],
            stops: const [0.0, 0.35, 0.72, 1.0],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AURORA GLOW LAYER
// ─────────────────────────────────────────────────────────────────────────────
class _AuroraLayer extends StatelessWidget {
  final AnimationController ctrl;
  final Size size;
  const _AuroraLayer({required this.ctrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => Stack(
        children: [
          // Top-right aurora blob
          Positioned(
            top: -size.height * 0.15,
            right: -size.width * 0.15,
            child: Container(
              width: size.width * 0.75,
              height: size.width * 0.75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color.lerp(
                      const Color(0xFF00FF88).withOpacity(0.18),
                      const Color(0xFF00D4FF).withOpacity(0.22),
                      ctrl.value,
                    )!,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Left aurora blob
          Positioned(
            top: size.height * 0.25,
            left: -size.width * 0.25,
            child: Container(
              width: size.width * 0.65,
              height: size.width * 0.65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color.lerp(
                      const Color(0xFF39FF14).withOpacity(0.12),
                      const Color(0xFF00FF9F).withOpacity(0.16),
                      ctrl.value,
                    )!,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Centre deep-glow
          Center(
            child: Container(
              width: size.width * 0.9,
              height: size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color.lerp(
                      const Color(0xFF004D2A).withOpacity(0.35),
                      const Color(0xFF006644).withOpacity(0.45),
                      ctrl.value,
                    )!,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BREATHING ORB
// ─────────────────────────────────────────────────────────────────────────────
class _BreathingOrb extends StatelessWidget {
  final Animation<double> scaleAnim;
  final Animation<double> opacityAnim;
  const _BreathingOrb({required this.scaleAnim, required this.opacityAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scaleAnim,
      builder: (_, __) => Transform.scale(
        scale: scaleAnim.value,
        child: Opacity(
          opacity: opacityAnim.value,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00FF99).withOpacity(0.22),
                  const Color(0xFF00CC77).withOpacity(0.14),
                  const Color(0xFF007744).withOpacity(0.07),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FF99).withOpacity(0.25),
                  blurRadius: 80,
                  spreadRadius: 20,
                ),
                BoxShadow(
                  color: const Color(0xFF00FFCC).withOpacity(0.18),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            // Inner ring
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF7DFFCE).withOpacity(0.35),
                    width: 1.5,
                  ),
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00FF99).withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AURORA DIVIDER  (animated width)
// ─────────────────────────────────────────────────────────────────────────────
class _AuraDivider extends StatelessWidget {
  final AnimationController ctrl;
  const _AuraDivider({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final w = 36.0 + ctrl.value * 24.0;
        return Container(
          width: w,
          height: 1.2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                const Color(0xFF7DFFCE).withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PARTICLE DATA
// ─────────────────────────────────────────────────────────────────────────────
class _Particle {
  final double x; // 0..1 horizontal position
  final double baseY; // 0..1 starting Y fraction
  final double size; // dot radius
  final double speed; // travel speed multiplier
  final double phase; // animation offset 0..1
  final double hue; // HSL hue

  const _Particle({
    required this.x,
    required this.baseY,
    required this.size,
    required this.speed,
    required this.phase,
    required this.hue,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// PARTICLE PAINTER  (fireflies rising upward)
// ─────────────────────────────────────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress; // 0..1 loop
  final Size size;

  const _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    for (final p in particles) {
      // Each particle has its own phase offset
      final t = (progress + p.phase) % 1.0;
      final y = canvasSize.height * (1.0 - t * p.speed * 1.4);
      // Only draw while within bounds
      if (y < -p.size || y > canvasSize.height + p.size) continue;

      final x =
          canvasSize.width * p.x + math.sin(t * math.pi * 2 + p.phase * 6) * 18;

      final opacity = (t < 0.15)
          ? t / 0.15
          : (t > 0.75)
              ? (1.0 - t) / 0.25
              : 1.0;

      final paint = Paint()
        ..color = HSLColor.fromAHSL(
          (opacity * 0.85).clamp(0.0, 1.0),
          p.hue,
          0.9,
          0.75,
        ).toColor()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);

      canvas.drawCircle(Offset(x, y), p.size * 0.6, paint);

      // Small glow ring around brighter particles
      if (p.size > 5) {
        final glowPaint = Paint()
          ..color = HSLColor.fromAHSL(
            (opacity * 0.25).clamp(0.0, 1.0),
            p.hue,
            0.95,
            0.85,
          ).toColor()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7.0);
        canvas.drawCircle(Offset(x, y), p.size * 1.4, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// GARDEN SILHOUETTE PAINTER
// Draws layered treeline + ground glow at the bottom of the screen
// ─────────────────────────────────────────────────────────────────────────────
class _GardenPainter extends CustomPainter {
  final double progress; // 0..1, driven by breathe controller

  const _GardenPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Ground fog ────────────────────────────────────────────────────────
    final fogPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFF003322).withOpacity(0.9),
          const Color(0xFF004433).withOpacity(0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), fogPaint);

    // ── Back tree layer (darkest) ─────────────────────────────────────────
    _drawTreeLayer(
      canvas,
      size,
      baseY: h * 0.72,
      treeHeight: h * 0.52,
      color: const Color(0xFF001A0E),
      count: 9,
      widthMult: 1.0,
      yOffset: math.sin(progress * math.pi) * 3,
    );

    // ── Mid tree layer ────────────────────────────────────────────────────
    _drawTreeLayer(
      canvas,
      size,
      baseY: h * 0.82,
      treeHeight: h * 0.42,
      color: const Color(0xFF002B16),
      count: 11,
      widthMult: 0.85,
      yOffset: math.sin(progress * math.pi + 0.5) * 5,
    );

    // ── Front tree layer (lightest silhouette) ────────────────────────────
    _drawTreeLayer(
      canvas,
      size,
      baseY: h * 0.94,
      treeHeight: h * 0.36,
      color: const Color(0xFF003D1E),
      count: 14,
      widthMult: 0.7,
      yOffset: math.sin(progress * math.pi + 1.0) * 7,
    );

    // ── Ground glow strip ─────────────────────────────────────────────────
    final groundGlow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFF00FF88).withOpacity(0.06 + progress * 0.04),
          const Color(0xFF00FF88).withOpacity(0.12 + progress * 0.06),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.85, w, h * 0.15));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.85, w, h * 0.15), groundGlow);
  }

  void _drawTreeLayer(
    Canvas canvas,
    Size size, {
    required double baseY,
    required double treeHeight,
    required Color color,
    required int count,
    required double widthMult,
    required double yOffset,
  }) {
    final paint = Paint()..color = color;
    final w = size.width;
    final spacing = w / count;

    for (int i = 0; i < count; i++) {
      final cx = spacing * i + spacing * 0.5 + (i % 3 - 1) * spacing * 0.2;
      final top = baseY - treeHeight * (0.7 + (i % 5) * 0.08) + yOffset;
      final halfW = spacing * widthMult * 0.48;

      final path = Path()
        ..moveTo(cx, top)
        ..lineTo(cx - halfW, baseY + yOffset)
        ..lineTo(cx + halfW, baseY + yOffset)
        ..close();

      // Second tier of triangle (layered pine look)
      final midY = top + treeHeight * 0.3;
      final pathMid = Path()
        ..moveTo(cx, top + treeHeight * 0.15)
        ..lineTo(cx - halfW * 1.2, midY + treeHeight * 0.3 + yOffset)
        ..lineTo(cx + halfW * 1.2, midY + treeHeight * 0.3 + yOffset)
        ..close();

      canvas.drawPath(pathMid, paint);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_GardenPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// LOTUS PETAL PAINTER  (gently drifting)
// ─────────────────────────────────────────────────────────────────────────────
class _PetalPainter extends CustomPainter {
  final double sway; // 0..1
  final Size size;

  const _PetalPainter({required this.sway, required this.size});

  static const _petalData = [
    (0.12, 0.55, 0.0),
    (0.28, 0.38, 0.3),
    (0.68, 0.44, 0.6),
    (0.82, 0.30, 0.1),
    (0.50, 0.62, 0.8),
    (0.92, 0.55, 0.5),
    (0.07, 0.72, 0.9),
    (0.44, 0.22, 0.4),
  ];

  @override
  void paint(Canvas canvas, Size canvasSize) {
    for (final (px, py, phase) in _petalData) {
      final angle = (sway + phase) * math.pi * 0.4 - math.pi * 0.2;
      final x = canvasSize.width * px + math.sin(angle) * 12;
      final y = canvasSize.height * py + math.cos((sway + phase) * math.pi) * 8;

      final opacity = 0.12 + 0.10 * math.sin((sway + phase) * math.pi);
      _drawPetal(canvas, Offset(x, y), angle, opacity);
    }
  }

  void _drawPetal(Canvas canvas, Offset center, double angle, double opacity) {
    final paint = Paint()
      ..color = const Color(0xFF7DFFCE).withOpacity(opacity)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final path = Path()
      ..moveTo(0, 0)
      ..cubicTo(-10, -18, -6, -34, 0, -38)
      ..cubicTo(6, -34, 10, -18, 0, 0);

    canvas.drawPath(path, paint);

    // Vein
    final veinPaint = Paint()
      ..color = const Color(0xFFB8FFE8).withOpacity(opacity * 0.6)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(0, 0), const Offset(0, -36), veinPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PetalPainter old) => old.sway != sway;
}

// ─────────────────────────────────────────────────────────────────────────────
// LOADING PANEL
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingPanel extends StatelessWidget {
  final String message;
  final double progress; // 0..1
  final AnimationController progressCtrl;
  final bool isComplete;

  const _LoadingPanel({
    required this.message,
    required this.progress,
    required this.progressCtrl,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF020D08).withOpacity(0.85),
            const Color(0xFF010A06),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Message
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: child,
            ),
            child: Text(
              message,
              key: ValueKey(message),
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF9EFFD0).withOpacity(0.75),
                letterSpacing: 1.8,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Progress bar track
          Stack(
            children: [
              // Track
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF88).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Fill
              AnimatedBuilder(
                animation: progressCtrl,
                builder: (_, __) => FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF00FF88),
                          Color(0xFF00FFCC),
                          Color(0xFF7DFFCE),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FF88).withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Glowing tip dot
              AnimatedBuilder(
                animation: progressCtrl,
                builder: (_, __) {
                  return FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFB8FFE8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FF99).withOpacity(0.9),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Percentage
          AnimatedBuilder(
            animation: progressCtrl,
            builder: (_, __) => Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                color: const Color(0xFF7DFFCE).withOpacity(0.55),
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ERROR DIALOG
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorDialog extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onContinue;

  const _ErrorDialog({required this.onRetry, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF051A10), Color(0xFF0A2E1A)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF00FF88).withOpacity(0.2),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FF88).withOpacity(0.15),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00FF88).withOpacity(0.4),
                  width: 1.5,
                ),
                color: const Color(0xFF00FF88).withOpacity(0.08),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  size: 34, color: Color(0xFF7DFFCE)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Garden Unreachable',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'We\'ll continue in offline mode.\nYour garden still awaits.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7DFFCE),
                      side:
                          const BorderSide(color: Color(0xFF00FF88), width: 1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00CC66),
                      foregroundColor: const Color(0xFF001A0D),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Enter',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
