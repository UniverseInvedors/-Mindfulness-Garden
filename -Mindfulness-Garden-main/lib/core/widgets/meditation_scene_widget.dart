import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pranaverse/core/widgets/character/teacher_personality.dart';
import 'package:pranaverse/core/widgets/character/premium_character_renderer.dart';
import 'package:pranaverse/core/services/ambient_sound_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PUBLIC API
// ═══════════════════════════════════════════════════════════════════════════

/// Breathing phase — drives Zeno's body scale, aura colour, and pose.
enum BreathPhase { idle, inhale, hold, exhale, rest, complete }

/// Which yoga / meditation pose Zeno should hold.
enum ZenoPose {
  sitting, // default cross-legged meditation
  warrior, // Warrior I — standing, arms up
  tree, // Tree pose — one leg raised, hands at heart
  childPose, // Child's pose — folded forward
  downwardDog, // Downward-facing dog
  mountain, // Mountain pose — standing, arms at sides
  lotus, // Full lotus — seated, hands on knees
}

/// Scene environment — determines sky, ground, background elements, creatures.
enum SceneEnvironment {
  forest,
  ocean,
  mountain,
  cosmic,
  desert,
  zenTemple,
  garden,
}

/// Time of day — affects sky gradient, sun/moon position, creature activity.
enum SceneTimeOfDay { dawn, morning, afternoon, dusk, night }

/// Get theme-based background image - changes with app theme
/// Returns null for cosmic (keep procedural) or breathing screens
String? _getThemeBackgroundImage(bool isDarkTheme) {
  // Use season images based on theme
  // Dark theme = night/winter vibes
  // Light theme = day/spring vibes
  if (isDarkTheme) {
    return 'assets/images/winter.jpeg'; // Winter/night scene
  } else {
    return 'assets/images/spring.jpeg'; // Spring/day scene
  }
}

// Keep old function for reference but not used in build
String? _getBackgroundImagePath(SceneEnvironment env) {
  switch (env) {
    case SceneEnvironment.forest:
      return 'assets/images/spring.jpeg';
    case SceneEnvironment.ocean:
      return 'assets/images/summer.jpeg';
    case SceneEnvironment.mountain:
      return 'assets/images/winter.jpeg';
    case SceneEnvironment.desert:
      return 'assets/images/summer.jpeg';
    case SceneEnvironment.zenTemple:
      return 'assets/images/autumn.jpeg';
    case SceneEnvironment.garden:
      return 'assets/images/moonsoon.jpeg';
    case SceneEnvironment.cosmic:
      return null; // Keep cosmic procedural
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET
// ═══════════════════════════════════════════════════════════════════════════

/// A fully self-contained 2.5D immersive scene for meditation and yoga.
///
/// Drop it anywhere — it owns all animation controllers and never mutates
/// external state.
///
/// ```dart
/// MeditationSceneWidget(
///   breathPhase: BreathPhase.inhale,
///   pose: ZenoPose.lotus,
///   environment: SceneEnvironment.forest,
///   SceneTimeOfDay: SceneTimeOfDay.morning,
///   instruction: 'Breathe in...',
///   isActive: true,
/// )
/// ```
class MeditationSceneWidget extends StatefulWidget {
  final BreathPhase breathPhase;
  final ZenoPose pose;
  final SceneEnvironment environment;
  final SceneTimeOfDay timeOfDay;
  final String instruction;
  final bool isActive;
  final double height;
  final TeacherPersonality teacher;

  const MeditationSceneWidget({
    super.key,
    this.breathPhase = BreathPhase.idle,
    this.pose = ZenoPose.sitting,
    this.environment = SceneEnvironment.forest,
    this.timeOfDay = SceneTimeOfDay.morning,
    this.instruction = '',
    this.isActive = false,
    this.height = 340,
    this.teacher = TeacherPersonality.buddha,
  });

  @override
  State<MeditationSceneWidget> createState() => _MeditationSceneWidgetState();
}

class _MeditationSceneWidgetState extends State<MeditationSceneWidget>
    with TickerProviderStateMixin {
  // Slow ambient loop — drives clouds, water ripples, leaf sway, stars twinkle
  late AnimationController _envCtrl;
  late Animation<double> _envAnim;

  // Body scale — driven by breathPhase
  late AnimationController _bodyCtrl;
  late Animation<double> _bodyScale;

  // Aura pulse
  late AnimationController _auraCtrl;
  late Animation<double> _auraAnim;

  // Creature movement (birds, fish, butterflies)
  late AnimationController _creatureCtrl;
  late Animation<double> _creatureAnim;

  // Pose transition
  late AnimationController _poseCtrl;
  late Animation<double> _poseAnim;
  ZenoPose _currentPose = ZenoPose.sitting;
  ZenoPose _targetPose = ZenoPose.sitting;

  // Life animations
  late AnimationController _blinkCtrl;
  late Animation<double> _blinkAnim;
  late AnimationController _swayCtrl;
  late Animation<double> _swayAnim;
  late AnimationController _idleBreathCtrl;
  late Animation<double> _idleBreathAnim;

  // Coach presence animations
  late AnimationController _gestureCtrl;
  late Animation<double> _gestureAnim;
  late AnimationController _successCtrl;
  late Animation<double> _successAnim;

  // Face and lip-sync loop for spoken guidance.
  late AnimationController _faceCtrl;
  late Animation<double> _faceAnim;

  final List<_Particle> _particles = [];
  final List<_Creature> _creatures = [];
  final Random _rng = Random();
  final _ambientSound = AmbientSoundService();

  @override
  void initState() {
    super.initState();

    // Start ambient sound for the environment
    if (widget.isActive) {
      _ambientSound.startAmbientSound(widget.environment);
    }

    _envCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
    _envAnim = Tween<double>(begin: 0, end: 1).animate(_envCtrl);

    _bodyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _bodyScale = const AlwaysStoppedAnimation(1.0);

    _auraCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _auraAnim = Tween<double>(
      begin: 0.35,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _auraCtrl, curve: Curves.easeInOut));

    _creatureCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _creatureAnim = Tween<double>(begin: 0, end: 1).animate(_creatureCtrl);

    _poseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _poseAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _poseCtrl, curve: Curves.easeInOut));
    _currentPose = widget.pose;
    _targetPose = widget.pose;
    // Ensure we update the current pose when the transition completes to avoid
    // lingering double-poses or stuck transitions.
    _poseCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentPose = _targetPose;
        });
      }
    });

    // Life animation controllers
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);
    _blinkAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _blinkCtrl, curve: Curves.easeInOut));

    _swayCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _swayAnim = Tween<double>(
      begin: -1,
      end: 1,
    ).animate(CurvedAnimation(parent: _swayCtrl, curve: Curves.easeInOut));

    _idleBreathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    // FIXED: Reduced from 0.98-1.02 to 1.0-1.0 to stop body breathing animation
    // Only aura and subtle effects should animate, not the body scale
    _idleBreathAnim = const AlwaysStoppedAnimation(1.0);

    // Coach presence animations
    _gestureCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _gestureAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _gestureCtrl, curve: Curves.easeInOut));

    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _successAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _successCtrl, curve: Curves.easeOutBack));

    _faceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _faceAnim = CurvedAnimation(parent: _faceCtrl, curve: Curves.easeInOut);
    _syncFaceLoop();

    _spawnParticles();
    _spawnCreatures();
    _applyBreathPhase(widget.breathPhase);
  }

  @override
  void didUpdateWidget(MeditationSceneWidget old) {
    super.didUpdateWidget(old);

    if (widget.isActive && !old.isActive) {
      _envCtrl.repeat();
      _auraCtrl.repeat(reverse: true);
      _creatureCtrl.repeat();
      _ambientSound.startAmbientSound(widget.environment);
    } else if (!widget.isActive && old.isActive) {
      _envCtrl.stop();
      _auraCtrl.stop();
      _creatureCtrl.stop();
      _bodyCtrl.stop();
      _ambientSound.pauseAmbientSound();
    }

    if (widget.instruction != old.instruction ||
        widget.isActive != old.isActive ||
        widget.breathPhase != old.breathPhase) {
      _syncFaceLoop();
      // Trigger gesture animation when instruction changes
      if (widget.instruction.isNotEmpty && widget.isActive) {
        _triggerGestureAnimation();
      }
    }

    // Trigger success animation when breath phase becomes complete
    if (widget.breathPhase == BreathPhase.complete &&
        old.breathPhase != BreathPhase.complete) {
      _triggerSuccessAnimation();
    }

    if (widget.breathPhase != old.breathPhase) {
      _applyBreathPhase(widget.breathPhase);
    }

    if (widget.pose != old.pose) {
      if (_poseCtrl.isAnimating) {
        _currentPose = _targetPose;
      } else {
        _currentPose = old.pose;
      }
      _targetPose = widget.pose;
      _poseCtrl.forward(from: 0);
    }

    if (widget.environment != old.environment) {
      _spawnParticles();
      _spawnCreatures();
      // Change ambient sound when environment changes
      if (widget.isActive) {
        _ambientSound.startAmbientSound(widget.environment);
      }
    }
  }

  bool get _isSpeaking {
    final text = widget.instruction.trim().toLowerCase();
    if (text.isEmpty ||
        text == 'choose your world' ||
        text.startsWith('tap start')) {
      return false;
    }
    return widget.isActive || widget.breathPhase != BreathPhase.idle;
  }

  void _syncFaceLoop() {
    if (_isSpeaking) {
      if (!_faceCtrl.isAnimating) {
        _faceCtrl.repeat(reverse: true);
      }
    } else {
      _faceCtrl.animateTo(0, duration: const Duration(milliseconds: 180));
    }
  }

  void _triggerGestureAnimation() {
    _gestureCtrl.forward(from: 0).then((_) {
      _gestureCtrl.reverse();
    });
  }

  void _triggerSuccessAnimation() {
    _successCtrl.forward(from: 0);
  }

  void _applyBreathPhase(BreathPhase phase) {
    // FIXED: Reduced body scale changes - was causing too much shake
    // Changed from 0.88-1.13 range to 0.96-1.04 for subtle effect
    final double target;
    switch (phase) {
      case BreathPhase.inhale:
        target = 1.03; // Was 1.13 - too much
        break;
      case BreathPhase.hold:
        target = 1.03; // Was 1.13 - too much
        break;
      case BreathPhase.exhale:
        target = 0.97; // Was 0.88 - too much
        break;
      case BreathPhase.rest:
        target = 0.99; // Was 0.94 - too much
        break;
      case BreathPhase.complete:
        target = 1.02; // Was 1.06 - too much
        break;
      case BreathPhase.idle:
        target = 1.00;
        break;
    }
    final current = _bodyCtrl.isAnimating ? (_bodyScale.value) : 1.0;
    _bodyScale = Tween<double>(
      begin: current,
      end: target,
    ).animate(CurvedAnimation(parent: _bodyCtrl, curve: Curves.easeInOut));
    _bodyCtrl
      ..reset()
      ..forward();
  }

  void _spawnParticles() {
    _particles.clear();
    final count = _particleCount;
    for (int i = 0; i < count; i++) {
      _particles.add(
        _Particle(
          x: _rng.nextDouble(),
          y: _rng.nextDouble() * 0.75,
          size: 1.5 + _rng.nextDouble() * 3.5,
          speed: 0.002 + _rng.nextDouble() * 0.006,
          phase: _rng.nextDouble() * pi * 2,
          drift: (_rng.nextDouble() - 0.5) * 0.003,
          type: _particleTypeForEnv,
        ),
      );
    }
  }

  void _spawnCreatures() {
    _creatures.clear();
    final defs = _creatureDefsForEnv;
    for (int i = 0; i < defs.length; i++) {
      _creatures.add(
        _Creature(
          type: defs[i],
          x: _rng.nextDouble(),
          y: 0.05 + _rng.nextDouble() * 0.45,
          speed: 0.008 + _rng.nextDouble() * 0.012,
          phase: _rng.nextDouble() * pi * 2,
          size: 0.7 + _rng.nextDouble() * 0.6,
        ),
      );
    }
  }

  int get _particleCount {
    switch (widget.environment) {
      case SceneEnvironment.cosmic:
        return 60; // Many stars
      case SceneEnvironment.forest:
        return 35; // Sakura petals, leaves for spring
      case SceneEnvironment.ocean:
        return 25; // Bubbles, light sparkles for summer
      case SceneEnvironment.mountain:
        return 45; // Snowflakes for winter
      case SceneEnvironment.garden:
        return 40; // Rain drops for monsoon
      case SceneEnvironment.zenTemple:
        return 30; // Falling leaves for autumn
      case SceneEnvironment.desert:
        return 20; // Light dust particles
    }
  }

  _ParticleType get _particleTypeForEnv {
    switch (widget.environment) {
      case SceneEnvironment.forest:
        return _ParticleType.petal; // Sakura petals for spring
      case SceneEnvironment.ocean:
        return _ParticleType.bubble; // Bubbles for summer
      case SceneEnvironment.cosmic:
        return _ParticleType.star; // Stars for cosmic
      case SceneEnvironment.desert:
        return _ParticleType.sand; // Sand for desert
      case SceneEnvironment.zenTemple:
        return _ParticleType.leaf; // Autumn leaves
      case SceneEnvironment.mountain:
        return _ParticleType.snow; // Snowflakes for winter
      case SceneEnvironment.garden:
        return _ParticleType.rain; // Rain for monsoon
    }
  }

  List<_CreatureType> get _creatureDefsForEnv {
    switch (widget.environment) {
      case SceneEnvironment.forest:
        return [
          _CreatureType.bird,
          _CreatureType.bird,
          _CreatureType.butterfly,
          _CreatureType.butterfly,
        ];
      case SceneEnvironment.ocean:
        return [_CreatureType.fish, _CreatureType.fish, _CreatureType.fish];
      case SceneEnvironment.mountain:
        return [_CreatureType.bird, _CreatureType.eagle];
      case SceneEnvironment.cosmic:
        return [_CreatureType.comet, _CreatureType.comet];
      case SceneEnvironment.desert:
        return [_CreatureType.bird];
      case SceneEnvironment.zenTemple:
        return [
          _CreatureType.butterfly,
          _CreatureType.butterfly,
          _CreatureType.bird,
        ];
      case SceneEnvironment.garden:
        return [
          _CreatureType.butterfly,
          _CreatureType.butterfly,
          _CreatureType.bird,
          _CreatureType.bee,
        ];
    }
  }

  Color get _phaseColor {
    switch (widget.breathPhase) {
      case BreathPhase.inhale:
        return const Color(0xFF00b4d8);
      case BreathPhase.hold:
        return const Color(0xFF9d4edd);
      case BreathPhase.exhale:
        return const Color(0xFF38b000);
      case BreathPhase.rest:
        return const Color(0xFFffb700);
      case BreathPhase.complete:
        return const Color(0xFF38b000);
      case BreathPhase.idle:
        return _envAccent;
    }
  }

  Color get _envAccent {
    switch (widget.environment) {
      case SceneEnvironment.forest:
        return const Color(0xFF38b000);
      case SceneEnvironment.ocean:
        return const Color(0xFF0077b6);
      case SceneEnvironment.mountain:
        return const Color(0xFF4cc9f0);
      case SceneEnvironment.cosmic:
        return const Color(0xFF9d4edd);
      case SceneEnvironment.desert:
        return const Color(0xFFf77f00);
      case SceneEnvironment.zenTemple:
        return const Color(0xFFe9c46a);
      case SceneEnvironment.garden:
        return const Color(0xFFf72585);
    }
  }

  @override
  void dispose() {
    _ambientSound.stopAmbientSound();
    _envCtrl.dispose();
    _bodyCtrl.dispose();
    _auraCtrl.dispose();
    _creatureCtrl.dispose();
    _poseCtrl.dispose();
    _faceCtrl.dispose();
    _blinkCtrl.dispose();
    _swayCtrl.dispose();
    _idleBreathCtrl.dispose();
    _gestureCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get theme-based background (not environment-based)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgImagePath = _getThemeBackgroundImage(isDark);

    return RepaintBoundary(
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            // Full background image layer - theme-based
            if (bgImagePath != null)
              Positioned.fill(
                child: Image.asset(
                  bgImagePath,
                  fit: BoxFit.cover, // Full coverage
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(),
                  // Full opacity - no transparency
                ),
              ),
            // Animated scene overlay
            AnimatedBuilder(
              animation: Listenable.merge([
                _envAnim,
                _bodyScale,
                _auraAnim,
                _creatureAnim,
                _poseAnim,
                _faceAnim,
                _blinkAnim,
                _swayAnim,
                _idleBreathAnim,
                _gestureAnim,
                _successAnim,
              ]),
              builder: (context, _) {
                return CustomPaint(
                  painter: _ScenePainter(
                    envT: _envAnim.value,
                    bodyScale: _bodyScale.value * _idleBreathAnim.value,
                    auraT: _auraAnim.value,
                    creatureT: _creatureAnim.value,
                    poseT: _poseAnim.value,
                    lipT: _faceAnim.value,
                    blinkT: _blinkAnim.value,
                    swayT: _swayAnim.value,
                    gestureT: _gestureAnim.value,
                    successT: _successAnim.value,
                    currentPose: _currentPose,
                    targetPose: _targetPose,
                    particles: _particles,
                    creatures: _creatures,
                    phaseColor: _phaseColor,
                    envAccent: _envAccent,
                    instruction: widget.instruction,
                    breathPhase: widget.breathPhase,
                    environment: widget.environment,
                    timeOfDay: widget.timeOfDay,
                    isActive: widget.isActive,
                    isSpeaking: _isSpeaking,
                    teacher: widget.teacher,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class _ScenePainter extends CustomPainter {
  final double envT,
      bodyScale,
      auraT,
      creatureT,
      poseT,
      lipT,
      blinkT,
      swayT,
      gestureT,
      successT;
  final ZenoPose currentPose, targetPose;
  final List<_Particle> particles;
  final List<_Creature> creatures;
  final Color phaseColor, envAccent;
  final String instruction;
  final BreathPhase breathPhase;
  final SceneEnvironment environment;
  final SceneTimeOfDay timeOfDay;
  final bool isActive, isSpeaking;
  final TeacherPersonality teacher;

  _ScenePainter({
    required this.envT,
    required this.bodyScale,
    required this.auraT,
    required this.creatureT,
    required this.poseT,
    required this.lipT,
    required this.blinkT,
    required this.swayT,
    required this.gestureT,
    required this.successT,
    required this.currentPose,
    required this.targetPose,
    required this.particles,
    required this.creatures,
    required this.phaseColor,
    required this.envAccent,
    required this.instruction,
    required this.breathPhase,
    required this.environment,
    required this.timeOfDay,
    required this.isActive,
    required this.isSpeaking,
    required this.teacher,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawCelestialBody(canvas, size);
    _drawBackgroundElements(canvas, size);
    _drawMidground(canvas, size);
    _drawGround(canvas, size);
    _drawGroundGlow(canvas, size);
    _drawParticles(canvas, size);
    _drawCreatures(canvas, size);
    _drawPremiumCharacter(canvas, size);
    if (instruction.isNotEmpty) _drawSpeechBubble(canvas, size);
  }

  // ── Sky ──────────────────────────────────────────────────────────────────
  void _drawSky(Canvas canvas, Size size) {
    // Try to draw background image based on environment first
    _drawBackgroundImage(canvas, size);

    // Then overlay the gradient sky for atmospheric effect
    final colors = _skyColors;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.68))
      ..blendMode = BlendMode.overlay; // Blend with background image
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.68), paint);
  }

  // ── Background Image ──────────────────────────────────────────────────────
  void _drawBackgroundImage(Canvas canvas, Size size) {
    // Map seasons to background images from assets/images/
    String? imagePath;
    switch (environment) {
      case SceneEnvironment.forest:
        imagePath = 'assets/images/spring.jpeg';
        break;
      case SceneEnvironment.ocean:
        imagePath = 'assets/images/summer.jpeg';
        break;
      case SceneEnvironment.mountain:
        imagePath = 'assets/images/winter.jpeg';
        break;
      case SceneEnvironment.cosmic:
        imagePath = null; // Keep cosmic procedural
        break;
      case SceneEnvironment.desert:
        imagePath = 'assets/images/summer.jpeg';
        break;
      case SceneEnvironment.zenTemple:
        imagePath = 'assets/images/autumn.jpeg';
        break;
      case SceneEnvironment.garden:
        imagePath = 'assets/images/moonsoon.jpeg';
        break;
    }

    // Note: This is a placeholder - actual image loading would require
    // using Image widget or ui.Image with ImageProvider
    // For now, the gradient overlay provides the atmosphere
  }

  List<Color> get _skyColors {
    switch (timeOfDay) {
      case SceneTimeOfDay.dawn:
        return [
          const Color(0xFF1a0533),
          const Color(0xFFf77f00),
          const Color(0xFFffb700),
        ];
      case SceneTimeOfDay.morning:
        return [
          const Color(0xFF0a1628),
          const Color(0xFF1a4a7a),
          const Color(0xFF4cc9f0),
        ];
      case SceneTimeOfDay.afternoon:
        return [
          const Color(0xFF0d47a1),
          const Color(0xFF1976d2),
          const Color(0xFF90caf9),
        ];
      case SceneTimeOfDay.dusk:
        return [
          const Color(0xFF1a0533),
          const Color(0xFFb5179e),
          const Color(0xFFf77f00),
        ];
      case SceneTimeOfDay.night:
        return [
          const Color(0xFF000010),
          const Color(0xFF0a0a2e),
          const Color(0xFF0d1b2a),
        ];
    }
  }

  // ── Sun / Moon ────────────────────────────────────────────────────────────
  void _drawCelestialBody(Canvas canvas, Size size) {
    final isNight = timeOfDay == SceneTimeOfDay.night;
    final isDusk =
        timeOfDay == SceneTimeOfDay.dusk || timeOfDay == SceneTimeOfDay.dawn;

    // Position arcs across the sky with envT
    final t = (envT + 0.25) % 1.0;
    final cx = size.width * (0.1 + t * 0.8);
    final cy = size.height * (0.05 + 0.18 * sin(t * pi).clamp(0.0, 1.0));

    if (isNight) {
      // Moon
      final moonPaint = Paint()..color = const Color(0xFFe8e8d0);
      canvas.drawCircle(Offset(cx, cy), 18, moonPaint);
      // Moon shadow
      final shadowPaint = Paint()..color = const Color(0xFF0a0a2e);
      canvas.drawCircle(Offset(cx + 6, cy - 4), 15, shadowPaint);
      // Stars
      final starPaint = Paint()..color = Colors.white.withAlpha(200);
      for (int i = 0; i < 40; i++) {
        final sx = (sin(i * 137.5 * pi / 180) * 0.5 + 0.5) * size.width;
        final sy = (cos(i * 97.3 * pi / 180) * 0.5 + 0.5) * size.height * 0.55;
        final twinkle = 0.4 + 0.6 * sin(envT * pi * 2 * (1 + i % 3) + i);
        starPaint.color = Colors.white.withAlpha((twinkle * 200).toInt());
        canvas.drawCircle(Offset(sx, sy), 1.0 + (i % 3) * 0.5, starPaint);
      }
    } else {
      // Sun
      final sunColor =
          isDusk ? const Color(0xFFf77f00) : const Color(0xFFFFD700);
      final glowPaint = Paint()
        ..color = sunColor.withAlpha(60)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(Offset(cx, cy), 32, glowPaint);
      final sunPaint = Paint()
        ..shader = RadialGradient(
          colors: [Colors.white, sunColor],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 18));
      canvas.drawCircle(Offset(cx, cy), 18, sunPaint);
    }
  }

  // ── Background environment elements ──────────────────────────────────────
  void _drawBackgroundElements(Canvas canvas, Size size) {
    switch (environment) {
      case SceneEnvironment.forest:
        _drawForestBg(canvas, size);
        break;
      case SceneEnvironment.ocean:
        _drawOceanBg(canvas, size);
        break;
      case SceneEnvironment.mountain:
        _drawMountainBg(canvas, size);
        break;
      case SceneEnvironment.cosmic:
        _drawCosmicBg(canvas, size);
        break;
      case SceneEnvironment.desert:
        _drawDesertBg(canvas, size);
        break;
      case SceneEnvironment.zenTemple:
        _drawTempleBg(canvas, size);
        break;
      case SceneEnvironment.garden:
        _drawGardenBg(canvas, size);
        break;
    }
  }

  void _drawForestBg(Canvas canvas, Size size) {
    // Skip tree rendering - background image already has complete scenery
    // Only draw fog layer for atmosphere
    final fogPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, const Color(0xFF4cc9f0).withAlpha(20)],
      ).createShader(
        Rect.fromLTWH(0, size.height * 0.45, size.width, size.height * 0.2),
      );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.45, size.width, size.height * 0.2),
      fogPaint,
    );
  }

  void _drawTree(
    Canvas canvas,
    Size size,
    double xFrac,
    double heightFrac,
    double widthFrac,
    Paint paint,
  ) {
    final x = size.width * xFrac;
    final groundY = size.height * 0.63;
    final h = size.height * heightFrac;
    final w = size.width * widthFrac;
    // Trunk
    final trunkPaint = Paint()..color = const Color(0xFF3d1f00).withAlpha(160);
    canvas.drawRect(
      Rect.fromLTWH(x - w * 0.1, groundY - h * 0.3, w * 0.2, h * 0.3),
      trunkPaint,
    );
    // Canopy — triangle
    final path = Path()
      ..moveTo(x, groundY - h)
      ..lineTo(x - w / 2, groundY - h * 0.3)
      ..lineTo(x + w / 2, groundY - h * 0.3)
      ..close();
    canvas.drawPath(path, paint);
    // Second tier
    final path2 = Path()
      ..moveTo(x, groundY - h * 0.75)
      ..lineTo(x - w * 0.6, groundY - h * 0.2)
      ..lineTo(x + w * 0.6, groundY - h * 0.2)
      ..close();
    canvas.drawPath(path2, paint);
  }

  void _drawOceanBg(Canvas canvas, Size size) {
    // Distant ocean horizon
    final waterPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF0077b6), const Color(0xFF023e8a)],
      ).createShader(
        Rect.fromLTWH(0, size.height * 0.45, size.width, size.height * 0.2),
      );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.45, size.width, size.height * 0.2),
      waterPaint,
    );
    // Wave lines
    final wavePaint = Paint()
      ..color = Colors.white.withAlpha(40)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 4; i++) {
      final y = size.height * (0.50 + i * 0.025);
      final path = Path();
      path.moveTo(0, y);
      for (double x = 0; x <= size.width; x += 20) {
        path.lineTo(
          x,
          y + sin((x / size.width * pi * 4) + envT * pi * 2 + i) * 3,
        );
      }
      canvas.drawPath(path, wavePaint);
    }
  }

  void _drawMountainBg(Canvas canvas, Size size) {
    final mPaint = Paint()..color = const Color(0xFF1a3a5c).withAlpha(200);
    final mPaint2 = Paint()..color = const Color(0xFF2d6a9f).withAlpha(160);
    // Far mountains
    _drawMountainShape(canvas, size, 0.2, 0.35, 0.5, mPaint);
    _drawMountainShape(canvas, size, 0.6, 0.30, 0.45, mPaint);
    // Near mountains
    _drawMountainShape(canvas, size, 0.05, 0.28, 0.38, mPaint2);
    _drawMountainShape(canvas, size, 0.75, 0.32, 0.42, mPaint2);
    // Snow caps
    final snowPaint = Paint()..color = Colors.white.withAlpha(200);
    _drawSnowCap(canvas, size, 0.2, 0.35, snowPaint);
    _drawSnowCap(canvas, size, 0.6, 0.30, snowPaint);
  }

  void _drawMountainShape(
    Canvas canvas,
    Size size,
    double xFrac,
    double heightFrac,
    double widthFrac,
    Paint paint,
  ) {
    final x = size.width * xFrac;
    final groundY = size.height * 0.63;
    final h = size.height * heightFrac;
    final w = size.width * widthFrac;
    final path = Path()
      ..moveTo(x, groundY - h)
      ..lineTo(x - w / 2, groundY)
      ..lineTo(x + w / 2, groundY)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawSnowCap(
    Canvas canvas,
    Size size,
    double xFrac,
    double heightFrac,
    Paint paint,
  ) {
    final x = size.width * xFrac;
    final groundY = size.height * 0.63;
    final h = size.height * heightFrac;
    final path = Path()
      ..moveTo(x, groundY - h)
      ..lineTo(x - size.width * 0.04, groundY - h * 0.82)
      ..lineTo(x + size.width * 0.04, groundY - h * 0.82)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawCosmicBg(Canvas canvas, Size size) {
    // Nebula clouds
    final nebulaPaint = Paint()..style = PaintingStyle.fill;
    final nebulaColors = [
      const Color(0xFF9d4edd).withAlpha(40),
      const Color(0xFF00b4d8).withAlpha(30),
      const Color(0xFFf72585).withAlpha(25),
    ];
    final positions = [
      Offset(size.width * 0.2, size.height * 0.2),
      Offset(size.width * 0.75, size.height * 0.15),
      Offset(size.width * 0.5, size.height * 0.35),
    ];
    for (int i = 0; i < 3; i++) {
      nebulaPaint.color = nebulaColors[i];
      nebulaPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
      canvas.drawCircle(
        positions[i],
        80 + sin(envT * pi * 2 + i) * 15,
        nebulaPaint,
      );
    }
    nebulaPaint.maskFilter = null;
    // Distant planets
    final planetPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF9d4edd), const Color(0xFF3a0ca3)],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.82, size.height * 0.12),
          radius: 22,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.12),
      22,
      planetPaint,
    );
    // Planet ring
    final ringPaint = Paint()
      ..color = const Color(0xFF9d4edd).withAlpha(120)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.82, size.height * 0.12),
        width: 52,
        height: 14,
      ),
      ringPaint,
    );
  }

  void _drawDesertBg(Canvas canvas, Size size) {
    // Sand dunes
    final dunePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFFe9c46a), const Color(0xFFf4a261)],
      ).createShader(
        Rect.fromLTWH(0, size.height * 0.4, size.width, size.height * 0.25),
      );
    final dunePath = Path();
    dunePath.moveTo(0, size.height * 0.63);
    dunePath.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.42,
      size.width * 0.5,
      size.height * 0.55,
    );
    dunePath.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.68,
      size.width,
      size.height * 0.50,
    );
    dunePath.lineTo(size.width, size.height * 0.63);
    dunePath.close();
    canvas.drawPath(dunePath, dunePaint);
    // Cactus silhouettes
    final cactusPaint = Paint()..color = const Color(0xFF2d6a4f).withAlpha(180);
    _drawCactus(canvas, size, 0.12, cactusPaint);
    _drawCactus(canvas, size, 0.88, cactusPaint);
  }

  void _drawCactus(Canvas canvas, Size size, double xFrac, Paint paint) {
    final x = size.width * xFrac;
    final groundY = size.height * 0.63;
    // Main trunk
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 6, groundY - 70, 12, 70),
        const Radius.circular(6),
      ),
      paint,
    );
    // Left arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 26, groundY - 55, 22, 8),
        const Radius.circular(4),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 30, groundY - 75, 8, 22),
        const Radius.circular(4),
      ),
      paint,
    );
    // Right arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 4, groundY - 48, 22, 8),
        const Radius.circular(4),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 22, groundY - 68, 8, 22),
        const Radius.circular(4),
      ),
      paint,
    );
  }

  void _drawTempleBg(Canvas canvas, Size size) {
    // Temple pillars
    final pillarPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFe9c46a).withAlpha(200),
          const Color(0xFFa07850).withAlpha(180),
        ],
      ).createShader(Rect.fromLTWH(0, 0, 1, size.height));
    final groundY = size.height * 0.63;
    final pillarXs = [0.08, 0.22, 0.78, 0.92];
    for (final xFrac in pillarXs) {
      final x = size.width * xFrac;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 10, groundY - 120, 20, 120),
          const Radius.circular(4),
        ),
        pillarPaint,
      );
      // Capital
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 14, groundY - 128, 28, 12),
          const Radius.circular(3),
        ),
        pillarPaint,
      );
    }
    // Roof beam
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.06, groundY - 136, size.width * 0.88, 14),
        const Radius.circular(4),
      ),
      pillarPaint,
    );
    // Hanging lanterns
    final lanternPaint = Paint()
      ..color = const Color(0xFFf77f00).withAlpha(200)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final lanternXs = [0.3, 0.5, 0.7];
    for (final xFrac in lanternXs) {
      final lx = size.width * xFrac;
      final ly = groundY - 110 + sin(envT * pi * 2 + xFrac * 10) * 4;
      canvas.drawCircle(Offset(lx, ly), 8, lanternPaint);
    }
  }

  void _drawGardenBg(Canvas canvas, Size size) {
    // Flower bushes in background
    final flowerColors = [
      const Color(0xFFf72585),
      const Color(0xFFffb700),
      const Color(0xFF9d4edd),
      const Color(0xFF38b000),
    ];
    final positions = [0.05, 0.18, 0.75, 0.90];
    for (int i = 0; i < positions.length; i++) {
      final x = size.width * positions[i];
      final groundY = size.height * 0.63;
      final bushPaint = Paint()..color = const Color(0xFF2d6a4f).withAlpha(200);
      canvas.drawCircle(Offset(x, groundY - 25), 22, bushPaint);
      // Flowers on bush
      final fPaint = Paint()
        ..color = flowerColors[i % flowerColors.length].withAlpha(220);
      for (int j = 0; j < 5; j++) {
        final angle = j * pi * 2 / 5 + envT * pi * 0.5;
        canvas.drawCircle(
          Offset(x + cos(angle) * 14, groundY - 25 + sin(angle) * 10),
          5,
          fPaint,
        );
      }
    }
  }

  // ── Midground (near trees, rocks, water edge) ─────────────────────────────
  void _drawMidground(Canvas canvas, Size size) {
    final groundY = size.height * 0.63;
    switch (environment) {
      case SceneEnvironment.forest:
        // Skip trees - background image has complete scenery
        // Only keep grass tufts for subtle foreground detail
        _drawGrassTufts(canvas, size, groundY);
        break;
      case SceneEnvironment.ocean:
        // Coral / rocks at water edge
        final rockPaint = Paint()
          ..color = const Color(0xFF4a4e69).withAlpha(200);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(size.width * 0.15, groundY - 8),
            width: 50,
            height: 22,
          ),
          rockPaint,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(size.width * 0.85, groundY - 6),
            width: 40,
            height: 18,
          ),
          rockPaint,
        );
        break;
      case SceneEnvironment.zenTemple:
        // Stone path
        final stonePaint = Paint()
          ..color = const Color(0xFF6b705c).withAlpha(180);
        for (int i = 0; i < 5; i++) {
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(size.width / 2, groundY - 5 + i * 18.0),
              width: 30 - i * 3.0,
              height: 12,
            ),
            stonePaint,
          );
        }
        break;
      default:
        break;
    }
  }

  void _drawGrassTufts(Canvas canvas, Size size, double groundY) {
    final grassPaint = Paint()
      ..color = const Color(0xFF38b000).withAlpha(180)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final tufts = [0.02, 0.08, 0.14, 0.86, 0.92, 0.98];
    for (final xFrac in tufts) {
      final x = size.width * xFrac;
      final sway = sin(envT * pi * 2 + xFrac * 20) * 4;
      for (int i = -2; i <= 2; i++) {
        canvas.drawLine(
          Offset(x + i * 4, groundY),
          Offset(x + i * 4 + sway, groundY - 14),
          grassPaint,
        );
      }
    }
  }

  // ── Ground plane with perspective grid ─────────────────────────────────
  void _drawGround(Canvas canvas, Size size) {
    final groundY = size.height * 0.63;
    final groundH = size.height * 0.37;
    final groundColors = _groundColors;
    final groundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: groundColors,
      ).createShader(Rect.fromLTWH(0, groundY, size.width, groundH));
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, groundH),
      groundPaint,
    );

    final gridPaint = Paint()
      ..color = envAccent.withAlpha(22)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    const lineCount = 12;
    for (int i = 0; i <= lineCount; i++) {
      final t = i / lineCount;
      final y = groundY + groundH * t * 0.88;
      final xInset = size.width * 0.5 * (1 - t);
      canvas.drawLine(
        Offset(xInset, y),
        Offset(size.width - xInset, y),
        gridPaint,
      );
    }
    for (int i = 0; i <= lineCount; i++) {
      final t = i / lineCount;
      final xBottom = size.width * t;
      final xInset = size.width * 0.5;
      final xTop = xInset * (1 - t) + (size.width - xInset) * t;
      canvas.drawLine(
        Offset(xTop, groundY),
        Offset(xBottom, groundY + groundH * 0.88),
        gridPaint,
      );
    }
    final horizPaint = Paint()
      ..color = envAccent.withAlpha(55)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(0, groundY),
      Offset(size.width, groundY),
      horizPaint,
    );
  }

  List<Color> get _groundColors {
    switch (environment) {
      case SceneEnvironment.forest:
        return [const Color(0xFF1b4332), const Color(0xFF081c15)];
      case SceneEnvironment.ocean:
        return [const Color(0xFF023e8a), const Color(0xFF03045e)];
      case SceneEnvironment.mountain:
        return [const Color(0xFF1a3a5c), const Color(0xFF0d1b2a)];
      case SceneEnvironment.cosmic:
        return [const Color(0xFF10002b), const Color(0xFF000010)];
      case SceneEnvironment.desert:
        return [const Color(0xFFe9c46a), const Color(0xFFf4a261)];
      case SceneEnvironment.zenTemple:
        return [const Color(0xFF3d2b1f), const Color(0xFF1a0f0a)];
      case SceneEnvironment.garden:
        return [const Color(0xFF2d6a4f), const Color(0xFF1b4332)];
    }
  }

  // ── Ground glow under Zeno ──────────────────────────────────────────────
  void _drawGroundGlow(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final groundY = size.height * 0.63;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          phaseColor.withAlpha((90 * auraT).toInt()),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCenter(
          center: Offset(cx, groundY),
          width: size.width * 0.65,
          height: size.height * 0.16,
        ),
      );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, groundY),
        width: size.width * 0.65,
        height: size.height * 0.16,
      ),
      glowPaint,
    );
  }

  // ── Particles ──────────────────────────────────────────────────────────
  void _drawParticles(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final px =
          (p.x + sin(envT * pi * 2 * p.speed * 8 + p.phase) * p.drift * 12)
                  .clamp(0.0, 1.0) *
              size.width;
      final py = ((p.y - envT * p.speed * 0.4) % 1.0) * size.height;
      final opacity = (0.25 + 0.6 * sin(envT * pi * 2 + p.phase)).clamp(
        0.0,
        1.0,
      );
      switch (p.type) {
        case _ParticleType.leaf:
          paint.color = const Color(
            0xFF38b000,
          ).withAlpha((opacity * 200).toInt());
          canvas.save();
          canvas.translate(px, py);
          canvas.rotate(envT * pi * 4 + p.phase);
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size * 2.5,
              height: p.size,
            ),
            paint,
          );
          canvas.restore();
          break;
        case _ParticleType.petal:
          paint.color = const Color(
            0xFFf72585,
          ).withAlpha((opacity * 200).toInt());
          canvas.save();
          canvas.translate(px, py);
          canvas.rotate(envT * pi * 3 + p.phase);
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size * 2,
              height: p.size,
            ),
            paint,
          );
          canvas.restore();
          break;
        case _ParticleType.bubble:
          paint.color = Colors.white.withAlpha((opacity * 80).toInt());
          paint.style = PaintingStyle.stroke;
          paint.strokeWidth = 1;
          canvas.drawCircle(Offset(px, py), p.size, paint);
          paint.style = PaintingStyle.fill;
          break;
        case _ParticleType.star:
          paint.color = Colors.white.withAlpha((opacity * 220).toInt());
          canvas.drawCircle(Offset(px, py), p.size * 0.6, paint);
          break;
        case _ParticleType.sand:
          paint.color = const Color(
            0xFFe9c46a,
          ).withAlpha((opacity * 160).toInt());
          canvas.drawCircle(Offset(px, py), p.size * 0.5, paint);
          break;
        case _ParticleType.dust:
          paint.color = envAccent.withAlpha((opacity * 140).toInt());
          canvas.drawCircle(Offset(px, py), p.size * 0.7, paint);
          break;
        case _ParticleType.snow:
          // Snowflakes - white crystals falling gently
          paint.color = Colors.white.withAlpha((opacity * 200).toInt());
          paint.style = PaintingStyle.fill;
          canvas.drawCircle(Offset(px, py), p.size * 0.8, paint);
          // Add sparkle effect
          paint.color = Colors.white.withAlpha((opacity * 100).toInt());
          canvas.drawCircle(Offset(px, py), p.size * 1.5, paint);
          break;
        case _ParticleType.rain:
          // Rain drops - falling fast with trail
          paint.color =
              const Color(0xFF4cc9f0).withAlpha((opacity * 180).toInt());
          paint.style = PaintingStyle.stroke;
          paint.strokeWidth = p.size * 0.3;
          paint.strokeCap = StrokeCap.round;
          // Draw raindrop as short line falling down
          canvas.drawLine(
            Offset(px, py),
            Offset(px, py + p.size * 4),
            paint,
          );
          break;
      }
    }
  }

  // ── Creatures ──────────────────────────────────────────────────────────
  void _drawCreatures(Canvas canvas, Size size) {
    for (final c in creatures) {
      final x =
          ((c.x + creatureT * c.speed * 1.2 + c.phase * 0.1) % 1.2 - 0.1) *
              size.width;
      final y =
          c.y * size.height * 0.6 + sin(creatureT * pi * 2 * 2 + c.phase) * 8;
      canvas.save();
      canvas.translate(x, y);
      canvas.scale(c.size);
      switch (c.type) {
        case _CreatureType.bird:
          _drawBird(canvas, creatureT + c.phase);
          break;
        case _CreatureType.eagle:
          _drawBird(canvas, creatureT + c.phase, large: true);
          break;
        case _CreatureType.butterfly:
          _drawButterfly(canvas, creatureT + c.phase);
          break;
        case _CreatureType.fish:
          _drawFish(canvas);
          break;
        case _CreatureType.bee:
          _drawBee(canvas, creatureT + c.phase);
          break;
        case _CreatureType.comet:
          _drawComet(canvas);
          break;
      }
      canvas.restore();
    }
  }

  void _drawBird(Canvas canvas, double t, {bool large = false}) {
    final wingFlap = sin(t * pi * 8) * 0.4;
    final paint = Paint()
      ..color = Colors.white.withAlpha(200)
      ..strokeWidth = large ? 2.5 : 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final s = large ? 14.0 : 8.0;
    final leftPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-s * 0.6, -s * wingFlap, -s, 0);
    canvas.drawPath(leftPath, paint);
    final rightPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(s * 0.6, -s * wingFlap, s, 0);
    canvas.drawPath(rightPath, paint);
  }

  void _drawButterfly(Canvas canvas, double t) {
    final wingOpen = (sin(t * pi * 6) * 0.5 + 0.5);
    final paint = Paint()..style = PaintingStyle.fill;
    // Upper wings
    paint.color = const Color(0xFFf72585).withAlpha(200);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-8 * wingOpen, -4),
        width: 14 * wingOpen,
        height: 10,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(8 * wingOpen, -4),
        width: 14 * wingOpen,
        height: 10,
      ),
      paint,
    );
    // Lower wings
    paint.color = const Color(0xFFffb700).withAlpha(180);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-6 * wingOpen, 3),
        width: 10 * wingOpen,
        height: 7,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(6 * wingOpen, 3),
        width: 10 * wingOpen,
        height: 7,
      ),
      paint,
    );
    // Body
    paint.color = const Color(0xFF1a1a2e);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 3, height: 10),
      paint,
    );
  }

  void _drawFish(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF4cc9f0).withAlpha(200);
    // Body
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 18, height: 8),
      paint,
    );
    // Tail
    final tailPath = Path()
      ..moveTo(-9, 0)
      ..lineTo(-16, -5)
      ..lineTo(-16, 5)
      ..close();
    canvas.drawPath(tailPath, paint);
    // Eye
    paint.color = Colors.white;
    canvas.drawCircle(const Offset(5, -1), 2, paint);
    paint.color = Colors.black;
    canvas.drawCircle(const Offset(5.5, -1), 1, paint);
  }

  void _drawBee(Canvas canvas, double t) {
    final paint = Paint()..style = PaintingStyle.fill;
    // Body
    paint.color = const Color(0xFFffb700);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 10, height: 7),
      paint,
    );
    // Stripes
    paint.color = Colors.black.withAlpha(180);
    canvas.drawRect(const Rect.fromLTWH(-2, -3.5, 2, 7), paint);
    canvas.drawRect(const Rect.fromLTWH(2, -3.5, 2, 7), paint);
    // Wings
    paint.color = Colors.white.withAlpha(160);
    final wingFlap = sin(t * pi * 12) * 0.3;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-5, -6 - wingFlap * 3),
        width: 8,
        height: 5,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(5, -6 - wingFlap * 3),
        width: 8,
        height: 5,
      ),
      paint,
    );
  }

  void _drawComet(Canvas canvas) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white, Colors.transparent],
      ).createShader(Rect.fromLTWH(-40, -2, 40, 4))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(-40, 0), Offset.zero, paint);
    final headPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset.zero, 3, headPaint);
  }

  // ── Premium Character with smooth pose transitions ─────────────────────────
  void _drawPremiumCharacter(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final groundY = size.height * 0.63;

    // Get appearance configuration
    final appearance = TeacherAppearance.personalities[teacher]!;

    canvas.save();
    canvas.translate(cx, groundY);

    // REMOVED: Excessive body sway - was causing full body shake
    // REMOVED: Body scale animation - was making entire body shake
    // Keep body stable at 1.0 scale
    canvas.scale(1.0);

    // Apply ONLY hand gesture animation - subtle single hand movement
    final handOffsetY = gestureT > 0 ? sin(gestureT * pi) * -15 : 0.0;

    // Use premium renderer for sitting/lotus poses
    if (currentPose == ZenoPose.sitting || currentPose == ZenoPose.lotus) {
      final renderer = PremiumCharacterRenderer(
        appearance: appearance,
        bodyScale: 1.0, // Fixed scale - no body breathing animation
        auraIntensity: auraT,
        breathPhase: breathPhase,
        envT: envT,
        isSpeaking: isSpeaking,
        lipT: lipT,
      );
      renderer.drawCharacter(canvas, size);

      // Draw hand gesture separately - only moves hand, not body
      if (gestureT > 0) {
        _drawHandGesture(canvas, appearance, handOffsetY);
      }
    } else {
      // For active poses, use the existing pose system with enhanced rendering
      _drawEnhancedPose(canvas, currentPose, appearance);
    }

    // Draw success animation (hands together bow)
    if (successT > 0) {
      _drawSuccessGesture(canvas, appearance);
    }

    canvas.restore();
  }

  // Draw simple hand gesture - only hand moves, not body
  void _drawHandGesture(
      Canvas canvas, TeacherAppearance appearance, double offsetY) {
    final alpha = ((1.0 - (offsetY.abs() / 15)) * 180).toInt().clamp(0, 180);
    final handPaint = Paint()
      ..color = appearance.skinPrimary.withAlpha(alpha)
      ..style = PaintingStyle.fill;

    // Draw simple raised hand gesture (right hand)
    canvas.save();
    canvas.translate(35, -60 + offsetY);

    // Palm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-8, -12, 16, 20),
        const Radius.circular(8),
      ),
      handPaint,
    );

    // Fingers (simplified)
    for (int i = 0; i < 4; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-6 + i * 4.0, -14, 3, 10),
          const Radius.circular(1.5),
        ),
        handPaint,
      );
    }

    canvas.restore();
  }

  void _drawSuccessGesture(Canvas canvas, TeacherAppearance appearance) {
    final alpha = (successT * 255).toInt();
    final gesturePaint = Paint()
      ..color = appearance.skinPrimary.withAlpha(alpha);

    // Hands together in prayer position
    canvas.save();
    canvas.translate(0, -40);
    canvas.scale(successT);

    // Left hand
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-12, -20, 10, 25),
        const Radius.circular(5),
      ),
      gesturePaint,
    );

    // Right hand
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, -20, 10, 25),
        const Radius.circular(5),
      ),
      gesturePaint,
    );

    // Glow effect
    final glowPaint = Paint()
      ..color = appearance.auraPrimary.withAlpha((alpha * 0.5).toInt())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(Offset.zero, 35, glowPaint);

    canvas.restore();
  }

  void _drawEnhancedPose(
    Canvas canvas,
    ZenoPose pose,
    TeacherAppearance appearance,
  ) {
    // Environment-reactive aura colors
    final envAuraColor = _getEnvironmentAuraColor();
    final auraColor = _blendColors(appearance.auraPrimary, envAuraColor, 0.4);

    // Enhanced aura with environment-blended colors
    for (int i = 3; i >= 1; i--) {
      final auraPaint = Paint()
        ..color = auraColor.withAlpha((20 * auraT * i).toInt())
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 + i * 2);
      canvas.drawCircle(Offset.zero, 55.0 + i * 18 * auraT, auraPaint);
    }

    // Environment-reactive rim light
    _drawRimLight(canvas, appearance);

    // Shadow with environment tint
    final shadowColor = _getEnvironmentShadowColor();
    final shadowPaint = Paint()
      ..color = shadowColor.withAlpha(60)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 4), width: 75, height: 18),
      shadowPaint,
    );

    // Draw pose with personality colors
    _drawPoseWithPersonality(canvas, pose, appearance);
  }

  Color _getEnvironmentAuraColor() {
    switch (environment) {
      case SceneEnvironment.forest:
        return const Color(0xFF38b000);
      case SceneEnvironment.ocean:
        return const Color(0xFF0077b6);
      case SceneEnvironment.mountain:
        return const Color(0xFF4cc9f0);
      case SceneEnvironment.cosmic:
        return const Color(0xFF9d4edd);
      case SceneEnvironment.desert:
        return const Color(0xFFf77f00);
      case SceneEnvironment.zenTemple:
        return const Color(0xFFe9c46a);
      case SceneEnvironment.garden:
        return const Color(0xFFf72585);
    }
  }

  Color _getEnvironmentShadowColor() {
    switch (environment) {
      case SceneEnvironment.forest:
        return const Color(0xFF1b4332);
      case SceneEnvironment.ocean:
        return const Color(0xFF023e8a);
      case SceneEnvironment.mountain:
        return const Color(0xFF1a3a5c);
      case SceneEnvironment.cosmic:
        return const Color(0xFF240046);
      case SceneEnvironment.desert:
        return const Color(0xFF6a4400);
      case SceneEnvironment.zenTemple:
        return const Color(0xFF3d2b1f);
      case SceneEnvironment.garden:
        return const Color(0xFF2d6a4f);
    }
  }

  Color _blendColors(Color c1, Color c2, double ratio) {
    return Color.fromARGB(
      ((c1.alpha * (1 - ratio)) + (c2.alpha * ratio)).toInt(),
      ((c1.red * (1 - ratio)) + (c2.red * ratio)).toInt(),
      ((c1.green * (1 - ratio)) + (c2.green * ratio)).toInt(),
      ((c1.blue * (1 - ratio)) + (c2.blue * ratio)).toInt(),
    );
  }

  void _drawRimLight(Canvas canvas, TeacherAppearance appearance) {
    final rimColor = _getEnvironmentAuraColor();
    final rimPaint = Paint()
      ..color = rimColor.withAlpha((30 * auraT).toInt())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    // Add subtle rim light around character
    canvas.drawCircle(const Offset(-15, -30), 40, rimPaint);
    canvas.drawCircle(const Offset(15, -30), 40, rimPaint);

    // Add environment-specific particle effects around character
    _drawCharacterParticles(canvas, rimColor);
  }

  void _drawCharacterParticles(Canvas canvas, Color particleColor) {
    final particlePaint = Paint()..color = particleColor.withAlpha(80);

    switch (environment) {
      case SceneEnvironment.forest:
        // Floating leaves around character
        for (int i = 0; i < 5; i++) {
          final angle = envT * pi * 2 + i * pi * 0.4;
          final radius = 50 + sin(envT * pi * 2 + i) * 10;
          final x = cos(angle) * radius;
          final y = sin(angle) * radius - 20;
          canvas.save();
          canvas.translate(x, y);
          canvas.rotate(envT * pi * 2 + i);
          canvas.drawOval(
            Rect.fromCenter(center: Offset.zero, width: 6, height: 3),
            particlePaint,
          );
          canvas.restore();
        }
        break;
      case SceneEnvironment.ocean:
        // Water droplets/bubbles
        for (int i = 0; i < 4; i++) {
          final x = -30 + i * 20 + sin(envT * pi * 2 + i) * 5;
          final y = -40 + (envT * 20 + i * 15) % 60;
          canvas.drawCircle(Offset(x, -y), 2 + i * 0.5, particlePaint);
        }
        break;
      case SceneEnvironment.cosmic:
        // Sparkles/stars around character
        for (int i = 0; i < 6; i++) {
          final angle = envT * pi * 2 + i * pi * 0.33;
          final radius = 45 + sin(envT * pi * 4 + i) * 15;
          final x = cos(angle) * radius;
          final y = sin(angle) * radius - 25;
          final sparkle = 0.5 + 0.5 * sin(envT * pi * 6 + i);
          canvas.drawCircle(Offset(x, y), 1.5 * sparkle, particlePaint);
        }
        break;
      case SceneEnvironment.mountain:
        // Snowflakes
        for (int i = 0; i < 4; i++) {
          final x = -25 + i * 16 + sin(envT * pi * 2 + i) * 8;
          final y = -30 + (envT * 15 + i * 12) % 50;
          canvas.drawCircle(Offset(x, -y), 2, particlePaint);
        }
        break;
      case SceneEnvironment.desert:
        // Sand particles
        for (int i = 0; i < 5; i++) {
          final x = -30 + i * 15 + sin(envT * pi * 2 + i) * 6;
          final y = -35 + (envT * 18 + i * 10) % 55;
          canvas.drawCircle(Offset(x, -y), 1.5, particlePaint);
        }
        break;
      case SceneEnvironment.zenTemple:
        // Incense smoke wisps
        for (int i = 0; i < 3; i++) {
          final x = (-15 + i * 15).toDouble();
          final y = (-50 - (envT * 20 + i * 15) % 40).toDouble();
          final smokePaint = Paint()
            ..color = particleColor.withAlpha(40)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
          canvas.drawCircle(
            Offset(x, y),
            4.0 + sin(envT * pi * 2 + i.toDouble()) * 2.0,
            smokePaint,
          );
        }
        break;
      case SceneEnvironment.garden:
        // Petals
        for (int i = 0; i < 4; i++) {
          final angle = envT * pi * 2 + i * pi * 0.5;
          final radius = 40 + sin(envT * pi * 2 + i) * 12;
          final x = cos(angle) * radius;
          final y = sin(angle) * radius - 20;
          canvas.save();
          canvas.translate(x, y);
          canvas.rotate(envT * pi * 3 + i);
          canvas.drawOval(
            Rect.fromCenter(center: Offset.zero, width: 5, height: 2.5),
            particlePaint,
          );
          canvas.restore();
        }
        break;
    }
  }

  void _drawPoseWithPersonality(
    Canvas canvas,
    ZenoPose pose,
    TeacherAppearance appearance,
  ) {
    final bodyPaint = Paint()..color = appearance.clothPrimary.withAlpha(220);
    final skinPaint = Paint()..color = appearance.skinPrimary;

    switch (pose) {
      case ZenoPose.warrior:
        _drawWarriorPoseEnhanced(canvas, appearance, bodyPaint, skinPaint);
        break;
      case ZenoPose.tree:
        _drawTreePoseEnhanced(canvas, appearance, bodyPaint, skinPaint);
        break;
      case ZenoPose.childPose:
        _drawChildPoseEnhanced(canvas, appearance, bodyPaint, skinPaint);
        break;
      case ZenoPose.downwardDog:
        _drawDownwardDogPoseEnhanced(canvas, appearance, bodyPaint, skinPaint);
        break;
      case ZenoPose.mountain:
        _drawMountainPoseEnhanced(canvas, appearance, bodyPaint, skinPaint);
        break;
      default:
        _drawSittingPoseEnhanced(canvas, appearance, bodyPaint, skinPaint);
    }
  }

  void _drawWarriorPoseEnhanced(
    Canvas canvas,
    TeacherAppearance appearance,
    Paint bodyPaint,
    Paint skinPaint,
  ) {
    final chestLift = breathPhase == BreathPhase.inhale
        ? -2.0
        : breathPhase == BreathPhase.exhale
            ? 1.0
            : 0.0;

    // Back leg
    canvas.save();
    canvas.translate(20, 0);
    canvas.rotate(-0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-9, 0, 18, 56),
        const Radius.circular(9),
      ),
      bodyPaint,
    );
    canvas.restore();

    // Front leg
    canvas.save();
    canvas.translate(-15, 0);
    canvas.rotate(0.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-9, 0, 18, 48),
        const Radius.circular(9),
      ),
      bodyPaint,
    );
    canvas.restore();

    // Torso
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-18, -70, 36, 70),
        const Radius.circular(12),
      ),
      bodyPaint,
    );

    // Arms raised
    canvas.save();
    canvas.translate(-18, -65 + chestLift);
    canvas.rotate(-0.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-6, -40, 12, 40),
        const Radius.circular(6),
      ),
      bodyPaint,
    );
    canvas.restore();
    canvas.save();
    canvas.translate(18, -65 + chestLift);
    canvas.rotate(0.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-6, -40, 12, 40),
        const Radius.circular(6),
      ),
      bodyPaint,
    );
    canvas.restore();

    _drawHeadEnhanced(canvas, -85, appearance, skinPaint);
  }

  void _drawTreePoseEnhanced(
    Canvas canvas,
    TeacherAppearance appearance,
    Paint bodyPaint,
    Paint skinPaint,
  ) {
    final chestLift = breathPhase == BreathPhase.inhale
        ? -2.0
        : breathPhase == BreathPhase.exhale
            ? 1.0
            : 0.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-10, 0, 20, 58),
        const Radius.circular(10),
      ),
      bodyPaint,
    );

    canvas.save();
    canvas.translate(8, 20);
    canvas.rotate(0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-7, 0, 14, 35),
        const Radius.circular(7),
      ),
      bodyPaint,
    );
    canvas.restore();

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-18, -70, 36, 70),
        const Radius.circular(12),
      ),
      bodyPaint,
    );

    canvas.save();
    canvas.translate(-10, -80 + chestLift);
    canvas.rotate(-0.15);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-5, -35, 10, 35),
        const Radius.circular(5),
      ),
      bodyPaint,
    );
    canvas.restore();
    canvas.save();
    canvas.translate(10, -80 + chestLift);
    canvas.rotate(0.15);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-5, -35, 10, 35),
        const Radius.circular(5),
      ),
      bodyPaint,
    );
    canvas.restore();

    _drawHeadEnhanced(canvas, -88, appearance, skinPaint);
  }

  void _drawChildPoseEnhanced(
    Canvas canvas,
    TeacherAppearance appearance,
    Paint bodyPaint,
    Paint skinPaint,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-40, -18, 80, 18),
        const Radius.circular(9),
      ),
      bodyPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-24, 0, 48, 20),
        const Radius.circular(8),
      ),
      bodyPaint,
    );
    canvas.save();
    canvas.translate(-40, -14);
    canvas.rotate(-0.1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-30, -5, 30, 10),
        const Radius.circular(5),
      ),
      bodyPaint,
    );
    canvas.restore();
    canvas.save();
    canvas.translate(-40, -6);
    canvas.rotate(0.1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-30, -5, 30, 10),
        const Radius.circular(5),
      ),
      bodyPaint,
    );
    canvas.restore();
    canvas.drawCircle(const Offset(-50, -14), 14, bodyPaint);
  }

  void _drawDownwardDogPoseEnhanced(
    Canvas canvas,
    TeacherAppearance appearance,
    Paint bodyPaint,
    Paint skinPaint,
  ) {
    canvas.save();
    canvas.rotate(-0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-10, -60, 20, 60),
        const Radius.circular(10),
      ),
      bodyPaint,
    );
    canvas.restore();
    canvas.save();
    canvas.translate(-30, -10);
    canvas.rotate(0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-7, 0, 14, 40),
        const Radius.circular(7),
      ),
      bodyPaint,
    );
    canvas.restore();
    canvas.save();
    canvas.translate(20, -5);
    canvas.rotate(-0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-9, 0, 18, 52),
        const Radius.circular(9),
      ),
      bodyPaint,
    );
    canvas.restore();
    canvas.drawCircle(const Offset(-38, -8), 14, bodyPaint);
  }

  void _drawMountainPoseEnhanced(
    Canvas canvas,
    TeacherAppearance appearance,
    Paint bodyPaint,
    Paint skinPaint,
  ) {
    final chestLift = breathPhase == BreathPhase.inhale
        ? -2.0
        : breathPhase == BreathPhase.exhale
            ? 1.0
            : 0.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-20, 0, 16, 55),
        const Radius.circular(8),
      ),
      bodyPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(4, 0, 16, 55),
        const Radius.circular(8),
      ),
      bodyPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-18, -70, 36, 70),
        const Radius.circular(12),
      ),
      bodyPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-30, -65 + chestLift, 12, 50),
        const Radius.circular(6),
      ),
      bodyPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(18, -65, 12, 50),
        const Radius.circular(6),
      ),
      bodyPaint,
    );

    _drawHeadEnhanced(canvas, -88, appearance, skinPaint);
  }

  void _drawSittingPoseEnhanced(
    Canvas canvas,
    TeacherAppearance appearance,
    Paint bodyPaint,
    Paint skinPaint,
  ) {
    final chestLift = breathPhase == BreathPhase.inhale
        ? -2.0
        : breathPhase == BreathPhase.exhale
            ? 1.0
            : 0.0;

    _drawLimb(
      canvas,
      const [Offset(-4, -4), Offset(-30, 0), Offset(-8, 18), Offset(10, 22)],
      appearance.clothPrimary,
      width: 15,
    );
    _drawLimb(
      canvas,
      const [Offset(4, -4), Offset(26, 0), Offset(8, 18), Offset(-10, 22)],
      appearance.clothSecondary,
      width: 14,
    );

    final torsoPath = Path()
      ..moveTo(-22, -66 + chestLift)
      ..cubicTo(-34, -49, -31, -18, -20, -2)
      ..quadraticBezierTo(0, 8, 20, -2)
      ..cubicTo(31, -18, 34, -49, 22, -66 + chestLift)
      ..quadraticBezierTo(0, -78 + chestLift, -22, -66 + chestLift)
      ..close();

    final torsoPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          appearance.clothPrimary,
          appearance.clothSecondary,
          appearance.clothAccent,
        ],
      ).createShader(const Rect.fromLTWH(-35, -82, 70, 95));
    canvas.drawPath(torsoPath, torsoPaint);

    _drawLimb(
      canvas,
      [
        Offset(-22, -55 + chestLift),
        const Offset(-39, -35),
        const Offset(-27, -15),
        const Offset(-8, -20),
      ],
      appearance.clothPrimary,
      width: 10,
      highlight: Colors.white,
    );
    _drawLimb(
      canvas,
      [
        Offset(22, -55 + chestLift),
        const Offset(39, -35),
        const Offset(27, -15),
        const Offset(8, -20),
      ],
      appearance.clothPrimary,
      width: 10,
      highlight: Colors.white,
    );

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-9, -20), width: 13, height: 8),
      skinPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(9, -20), width: 13, height: 8),
      skinPaint,
    );

    _drawHeadEnhanced(canvas, -94 + chestLift, appearance, skinPaint);
  }

  void _drawHeadEnhanced(
    Canvas canvas,
    double yOffset,
    TeacherAppearance appearance,
    Paint skinPaint,
  ) {
    final headBob = isSpeaking ? sin(envT * pi * 12) * 0.65 : 0.0;
    final headCenter = Offset(0, yOffset + headBob);
    final headSize = 21.0 * appearance.headScale;

    final auraPaint = Paint()
      ..color = appearance.auraPrimary.withAlpha((18 * auraT).toInt())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(headCenter, 31, auraPaint);

    final neckPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [appearance.skinPrimary, appearance.skinSecondary],
      ).createShader(Rect.fromLTWH(-9, yOffset + 14, 18, 20));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-8, yOffset + 15, 16, 16),
        const Radius.circular(5),
      ),
      neckPaint,
    );

    final headPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          appearance.skinPrimary,
          appearance.skinSecondary,
          appearance.skinShadow,
        ],
        center: const Alignment(-0.2, -0.2),
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: headCenter, radius: headSize));
    canvas.drawOval(
      Rect.fromCenter(center: headCenter, width: 39, height: 44),
      headPaint,
    );

    _drawHairForPersonality(canvas, headCenter, headSize, appearance);
    _drawFaceFeatures(canvas, headCenter, headSize, appearance);
  }

  void _drawHairForPersonality(
    Canvas canvas,
    Offset headCenter,
    double headSize,
    TeacherAppearance appearance,
  ) {
    final hairPaint = Paint()..color = appearance.hairPrimary;

    switch (teacher) {
      case TeacherPersonality.buddha:
        final hairPath = Path()
          ..moveTo(-22, headCenter.dy - 2)
          ..cubicTo(
            -20,
            headCenter.dy - 25,
            -8,
            headCenter.dy - 35,
            6,
            headCenter.dy - 33,
          )
          ..cubicTo(
            18,
            headCenter.dy - 31,
            25,
            headCenter.dy - 15,
            22,
            headCenter.dy + 4,
          )
          ..quadraticBezierTo(15, headCenter.dy - 2, 10, headCenter.dy - 15)
          ..quadraticBezierTo(0, headCenter.dy - 22, -10, headCenter.dy - 12)
          ..quadraticBezierTo(-16, headCenter.dy - 2, -22, headCenter.dy - 2)
          ..close();
        canvas.drawPath(hairPath, hairPaint);
        final bunPaint = Paint()..color = appearance.hairSecondary;
        final bunPath = Path()
          ..moveTo(-10, headCenter.dy - 30)
          ..cubicTo(
            -14,
            headCenter.dy - 42,
            -2,
            headCenter.dy - 46,
            8,
            headCenter.dy - 44,
          )
          ..cubicTo(
            16,
            headCenter.dy - 42,
            18,
            headCenter.dy - 32,
            14,
            headCenter.dy - 28,
          )
          ..cubicTo(
            10,
            headCenter.dy - 26,
            0,
            headCenter.dy - 28,
            -10,
            headCenter.dy - 30,
          )
          ..close();
        canvas.drawPath(bunPath, bunPaint);
        break;
      case TeacherPersonality.zeno:
        final hairPath = Path()
          ..moveTo(-headSize * 0.9, headCenter.dy - headSize * 0.3)
          ..lineTo(-headSize * 0.85, headCenter.dy - headSize * 0.7)
          ..quadraticBezierTo(
            0,
            headCenter.dy - headSize * 0.95,
            headSize * 0.85,
            headCenter.dy - headSize * 0.7,
          )
          ..lineTo(headSize * 0.9, headCenter.dy - headSize * 0.3)
          ..close();
        canvas.drawPath(hairPath, hairPaint);
        break;
      case TeacherPersonality.monk:
        final stubblePaint = Paint()
          ..color = appearance.hairPrimary.withAlpha(60);
        canvas.drawCircle(headCenter, headSize * 0.95, stubblePaint);
        break;
      case TeacherPersonality.shiva:
        // Matted jata (same as premium renderer)
        final jataPath = Path()
          ..moveTo(-headSize * 0.9, headCenter.dy - headSize * 0.4)
          ..cubicTo(
            -headSize * 1.1,
            headCenter.dy - headSize * 1.0,
            -headSize * 0.5,
            headCenter.dy - headSize * 1.6,
            0,
            headCenter.dy - headSize * 1.5,
          )
          ..cubicTo(
            headSize * 0.5,
            headCenter.dy - headSize * 1.6,
            headSize * 1.1,
            headCenter.dy - headSize * 1.0,
            headSize * 0.9,
            headCenter.dy - headSize * 0.4,
          )
          ..close();
        canvas.drawPath(jataPath, hairPaint);
        break;
      case TeacherPersonality.tiger:
        // Warrior topknot
        final topknotPath = Path()
          ..moveTo(-headSize * 0.85, headCenter.dy - headSize * 0.5)
          ..cubicTo(
            -headSize * 0.7,
            headCenter.dy - headSize * 0.9,
            -headSize * 0.2,
            headCenter.dy - headSize * 1.0,
            0,
            headCenter.dy - headSize * 0.98,
          )
          ..cubicTo(
            headSize * 0.2,
            headCenter.dy - headSize * 1.0,
            headSize * 0.7,
            headCenter.dy - headSize * 0.9,
            headSize * 0.85,
            headCenter.dy - headSize * 0.5,
          )
          ..close();
        canvas.drawPath(topknotPath, hairPaint);
        canvas.drawCircle(
          Offset(headCenter.dx, headCenter.dy - headSize * 1.05),
          headSize * 0.22,
          Paint()..color = appearance.hairSecondary,
        );
        break;
    }
  }

  void _drawFaceFeatures(
    Canvas canvas,
    Offset headCenter,
    double headSize,
    TeacherAppearance appearance,
  ) {
    final blink = blinkT > 0.9;
    final eyeSize = 3.5 * appearance.eyeSize;
    final eyeY = headCenter.dy - headSize * 0.15;

    if (blink) {
      final eyePaint = Paint()
        ..color = appearance.skinShadow
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(-headSize * 0.35, eyeY),
        Offset(-headSize * 0.15, eyeY),
        eyePaint,
      );
      canvas.drawLine(
        Offset(headSize * 0.15, eyeY),
        Offset(headSize * 0.35, eyeY),
        eyePaint,
      );
    } else {
      final eyeWhite = Paint()..color = Colors.white;
      final eyeIris = Paint()..color = const Color(0xFF4a3728);
      final eyePupil = Paint()..color = Colors.black;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(-headSize * 0.25, eyeY),
          width: eyeSize * 2,
          height: eyeSize * 1.5,
        ),
        eyeWhite,
      );
      canvas.drawCircle(Offset(-headSize * 0.25, eyeY), eyeSize * 0.6, eyeIris);
      canvas.drawCircle(
        Offset(-headSize * 0.25, eyeY),
        eyeSize * 0.3,
        eyePupil,
      );

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(headSize * 0.25, eyeY),
          width: eyeSize * 2,
          height: eyeSize * 1.5,
        ),
        eyeWhite,
      );
      canvas.drawCircle(Offset(headSize * 0.25, eyeY), eyeSize * 0.6, eyeIris);
      canvas.drawCircle(Offset(headSize * 0.25, eyeY), eyeSize * 0.3, eyePupil);

      final highlightPaint = Paint()..color = Colors.white.withAlpha(200);
      canvas.drawCircle(
        Offset(-headSize * 0.25 - 1, eyeY - 1),
        1.0,
        highlightPaint,
      );
      canvas.drawCircle(
        Offset(headSize * 0.25 - 1, eyeY - 1),
        1.0,
        highlightPaint,
      );
    }

    final browPaint = Paint()
      ..color = appearance.hairPrimary
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final browY = eyeY - headSize * 0.2;
    final browLift = breathPhase == BreathPhase.inhale ? -2.0 : 0.0;
    canvas.drawArc(
      Rect.fromLTWH(-headSize * 0.4, browY + browLift, headSize * 0.25, 4),
      pi,
      pi,
      false,
      browPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(headSize * 0.15, browY + browLift, headSize * 0.25, 4),
      pi,
      pi,
      false,
      browPaint,
    );

    final nosePaint = Paint()
      ..color = appearance.skinShadow.withAlpha(150)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final nosePath = Path()
      ..moveTo(headCenter.dx, headCenter.dy + headSize * 0.1)
      ..lineTo(headCenter.dx, headCenter.dy + headSize * 0.25)
      ..lineTo(headCenter.dx - 2, headCenter.dy + headSize * 0.25);
    canvas.drawPath(nosePath, nosePaint);

    final mouthY = headCenter.dy + headSize * 0.35;
    final mouthWidth = 6.0 * appearance.mouthWidth;

    if (isSpeaking) {
      final mouthPaint = Paint()..color = appearance.skinShadow;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(headCenter.dx, mouthY),
          width: mouthWidth + lipT * 3,
          height: 3 + lipT * 5,
        ),
        mouthPaint,
      );
    } else {
      final mouthPaint = Paint()
        ..color = appearance.skinShadow
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final smileAmount = breathPhase == BreathPhase.complete ? 3.0 : 1.5;
      canvas.drawArc(
        Rect.fromLTWH(
          headCenter.dx - mouthWidth,
          mouthY,
          mouthWidth * 2,
          4 + smileAmount,
        ),
        0.1,
        pi - 0.2,
        false,
        mouthPaint,
      );
    }

    final cheekPaint = Paint()..color = const Color(0xFFf28a91).withAlpha(40);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-headSize * 0.5, headCenter.dy + headSize * 0.2),
        width: 6,
        height: 4,
      ),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(headSize * 0.5, headCenter.dy + headSize * 0.2),
        width: 6,
        height: 4,
      ),
      cheekPaint,
    );

    if (breathPhase == BreathPhase.complete) {
      final checkPaint = Paint()
        ..color = const Color(0xFF38b000)
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(-9, headCenter.dy)
        ..lineTo(-3, headCenter.dy + 7)
        ..lineTo(11, headCenter.dy - 10);
      canvas.drawPath(path, checkPaint);
    }
  }

  void _drawPose(Canvas canvas, double t, ZenoPose from, ZenoPose to) {
    // Lerp between poses by drawing both at different opacities
    if (t < 1.0 && from != to) {
      canvas.save();
      canvas.scale(1.0, 1.0);
      final fromPaint = Paint()
        ..color = Colors.white.withAlpha(((1 - t) * 255).toInt());
      _drawSinglePose(canvas, from, fromPaint);
      canvas.restore();
    }
    final toPaint = Paint()..color = Colors.white.withAlpha((t * 255).toInt());
    _drawSinglePose(canvas, to, toPaint);
  }

  void _drawSinglePose(Canvas canvas, ZenoPose pose, Paint _) {
    switch (pose) {
      case ZenoPose.sitting:
      case ZenoPose.lotus:
        _drawSittingPose(canvas);
        break;
      case ZenoPose.warrior:
        _drawWarriorPose(canvas);
        break;
      case ZenoPose.tree:
        _drawTreePose(canvas);
        break;
      case ZenoPose.childPose:
        _drawChildPose(canvas);
        break;
      case ZenoPose.downwardDog:
        _drawDownwardDogPose(canvas);
        break;
      case ZenoPose.mountain:
        _drawMountainPose(canvas);
        break;
    }
  }

  // ── Sitting / Lotus — Humanoid instructor pose ─────────────────────────
  void _drawLimb(
    Canvas canvas,
    List<Offset> joints,
    Color color, {
    double width = 12,
    Color? highlight,
  }) {
    if (joints.length < 2) return;

    final shadow = Paint()
      ..color = Colors.black.withAlpha(40)
      ..strokeWidth = width + 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final stroke = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final light = Paint()
      ..color = (highlight ?? Colors.white).withAlpha(55)
      ..strokeWidth = max(2, width * 0.22)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path()..moveTo(joints.first.dx, joints.first.dy);
    for (final joint in joints.skip(1)) {
      path.lineTo(joint.dx, joint.dy);
    }

    canvas.drawPath(path.shift(const Offset(1.5, 2)), shadow);
    canvas.drawPath(path, stroke);
    canvas.drawPath(path.shift(Offset(-width * 0.16, -width * 0.12)), light);

    final jointPaint = Paint()..color = color;
    for (final joint in joints) {
      canvas.drawCircle(joint, width * 0.46, jointPaint);
    }
  }

  void _drawJointDot(Canvas canvas, Offset joint, Color color, double radius) {
    canvas.drawCircle(
      joint,
      radius + 1.5,
      Paint()..color = Colors.black.withAlpha(35),
    );
    canvas.drawCircle(joint, radius, Paint()..color = color.withAlpha(235));
    canvas.drawCircle(
      joint.translate(-radius * 0.25, -radius * 0.3),
      max(1.2, radius * 0.28),
      Paint()..color = Colors.white.withAlpha(70),
    );
  }

  void _drawSittingPose(Canvas canvas) {
    // Tiger skin colors (Lord Shiva's traditional attire)
    final tigerOrange = const Color(0xFFff8c00);
    final tigerDark = const Color(0xFF8b4513);
    final tigerBlack = const Color(0xFF1a1a1a);
    final skin = const Color(0xFFf2bd8f);
    final breathe = sin(envT * pi * 2) * 2.0;
    final chestLift = breathPhase == BreathPhase.inhale
        ? -2.0
        : breathPhase == BreathPhase.exhale
            ? 1.4
            : breathe * 0.45;

    final legShadow = Paint()
      ..color = Colors.black.withAlpha(44)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 23), width: 118, height: 28),
      legShadow,
    );

    // Cross-legged sitting with tiger skin - improved position
    _drawLimb(
      canvas,
      const [Offset(-4, -4), Offset(-30, 0), Offset(-8, 18), Offset(10, 22)],
      tigerOrange,
      width: 15,
    );
    _drawLimb(
      canvas,
      const [Offset(4, -4), Offset(26, 0), Offset(8, 18), Offset(-10, 22)],
      tigerDark,
      width: 14,
    );

    final torsoPath = Path()
      ..moveTo(-22, -66 + chestLift)
      ..cubicTo(-34, -49, -31, -18, -20, -2)
      ..quadraticBezierTo(0, 8, 20, -2)
      ..cubicTo(31, -18, 34, -49, 22, -66 + chestLift)
      ..quadraticBezierTo(0, -78 + chestLift, -22, -66 + chestLift)
      ..close();

    // Tiger skin base
    final torsoPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [tigerOrange, tigerDark, tigerBlack],
        stops: const [0, 0.5, 1],
      ).createShader(const Rect.fromLTWH(-35, -82, 70, 95));
    canvas.drawPath(
      torsoPath.shift(const Offset(2, 3)),
      Paint()..color = Colors.black.withAlpha(35),
    );
    canvas.drawPath(torsoPath, torsoPaint);

    // Tiger stripes on torso
    final stripePaint = Paint()
      ..color = tigerBlack
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(-18, -60 + chestLift),
      Offset(-8, -55 + chestLift),
      stripePaint,
    );
    canvas.drawLine(
      Offset(-12, -50 + chestLift),
      Offset(-2, -45 + chestLift),
      stripePaint,
    );
    canvas.drawLine(
      Offset(8, -58 + chestLift),
      Offset(18, -52 + chestLift),
      stripePaint,
    );
    canvas.drawLine(
      Offset(5, -40 + chestLift),
      Offset(15, -35 + chestLift),
      stripePaint,
    );
    canvas.drawLine(
      Offset(-15, -35 + chestLift),
      Offset(-5, -30 + chestLift),
      stripePaint,
    );
    canvas.drawLine(
      Offset(10, -25 + chestLift),
      Offset(20, -20 + chestLift),
      stripePaint,
    );

    _drawLimb(
      canvas,
      [
        Offset(-22, -55 + chestLift),
        const Offset(-39, -35),
        const Offset(-27, -15),
        const Offset(-8, -20),
      ],
      tigerOrange,
      width: 10,
      highlight: Colors.white,
    );
    _drawLimb(
      canvas,
      [
        Offset(22, -55 + chestLift),
        const Offset(39, -35),
        const Offset(27, -15),
        const Offset(8, -20),
      ],
      tigerOrange,
      width: 10,
      highlight: Colors.white,
    );

    // Tiger stripes on arms
    canvas.drawLine(
      const Offset(-30, -40),
      const Offset(-25, -35),
      stripePaint,
    );
    canvas.drawLine(
      const Offset(-35, -25),
      const Offset(-30, -20),
      stripePaint,
    );
    canvas.drawLine(const Offset(30, -40), const Offset(35, -35), stripePaint);
    canvas.drawLine(const Offset(32, -25), const Offset(37, -20), stripePaint);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-9, -20), width: 13, height: 8),
      Paint()..color = skin,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(9, -20), width: 13, height: 8),
      Paint()..color = skin,
    );
    canvas.drawCircle(const Offset(0, -21), 3.2, Paint()..color = skin);

    for (final joint in const [
      Offset(-22, -55),
      Offset(22, -55),
      Offset(-39, -35),
      Offset(39, -35),
      Offset(-43, 7),
      Offset(43, 7),
    ]) {
      _drawJointDot(canvas, joint, tigerOrange, 3.2);
    }

    _drawHead(canvas, yOffset: -94 + chestLift);
  }

  // ── Warrior I ─────────────────────────────────────────────────────────────
  void _drawWarriorPose(Canvas canvas) {
    final bodyPaint = Paint()..color = phaseColor.withAlpha(220);

    // Back leg - improved proportions
    canvas.save();
    canvas.translate(20, 0);
    canvas.rotate(-0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-9, 0, 18, 56),
        const Radius.circular(9),
      ),
      bodyPaint,
    );
    canvas.restore();
    // Front leg (bent) - improved proportions
    canvas.save();
    canvas.translate(-15, 0);
    canvas.rotate(0.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-9, 0, 18, 48),
        const Radius.circular(9),
      ),
      bodyPaint,
    );
    canvas.restore();

    // Torso upright
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-18, -70, 36, 70),
        const Radius.circular(12),
      ),
      bodyPaint,
    );

    // Arms raised overhead
    canvas.save();
    canvas.translate(-18, -65);
    canvas.rotate(-0.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-6, -40, 12, 40),
        const Radius.circular(6),
      ),
      bodyPaint,
    );
    canvas.restore();
    canvas.save();
    canvas.translate(18, -65);
    canvas.rotate(0.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-6, -40, 12, 40),
        const Radius.circular(6),
      ),
      bodyPaint,
    );
    canvas.restore();

    _drawHead(canvas, yOffset: -85);
  }

  // ── Tree pose ─────────────────────────────────────────────────────────────
  void _drawTreePose(Canvas canvas) {
    final bodyPaint = Paint()..color = phaseColor.withAlpha(220);

    // Standing leg - improved proportions for better realism
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-10, 0, 20, 58),
        const Radius.circular(10),
      ),
      bodyPaint,
    );
    // Raised leg (bent at knee, foot on inner thigh) - improved proportions
    canvas.save();
    canvas.translate(8, 20);
    canvas.rotate(0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-7, 0, 14, 35),
        const Radius.circular(7),
      ),
      bodyPaint,
    );
    canvas.restore();

    // Torso
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-18, -70, 36, 70),
        const Radius.circular(12),
      ),
      bodyPaint,
    );

    // Arms in prayer overhead
    canvas.save();
    canvas.translate(-10, -80);
    canvas.rotate(-0.15);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-5, -35, 10, 35),
        const Radius.circular(5),
      ),
      bodyPaint,
    );
    canvas.restore();
    canvas.save();
    canvas.translate(10, -80);
    canvas.rotate(0.15);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-5, -35, 10, 35),
        const Radius.circular(5),
      ),
      bodyPaint,
    );
    canvas.restore();

    _drawHead(canvas, yOffset: -88);
  }

  // ── Child's pose ──────────────────────────────────────────────────────────
  void _drawChildPose(Canvas canvas) {
    final bodyPaint = Paint()..color = phaseColor.withAlpha(220);

    // Folded body — horizontal
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-40, -18, 80, 18),
        const Radius.circular(9),
      ),
      bodyPaint,
    );
    // Legs folded under - improved proportions
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-24, 0, 48, 20),
        const Radius.circular(8),
      ),
      bodyPaint,
    );
    // Arms stretched forward
    canvas.save();
    canvas.translate(-40, -14);
    canvas.rotate(-0.1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-30, -5, 30, 10),
        const Radius.circular(5),
      ),
      bodyPaint,
    );
    canvas.restore();
    canvas.save();
    canvas.translate(-40, -6);
    canvas.rotate(0.1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-30, -5, 30, 10),
        const Radius.circular(5),
      ),
      bodyPaint,
    );
    canvas.restore();
    // Head down
    canvas.drawCircle(const Offset(-50, -14), 14, bodyPaint);
  }

  // ── Downward dog ──────────────────────────────────────────────────────────
  void _drawDownwardDogPose(Canvas canvas) {
    final bodyPaint = Paint()..color = phaseColor.withAlpha(220);

    // Inverted V shape — torso diagonal
    canvas.save();
    canvas.rotate(-0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-10, -60, 20, 60),
        const Radius.circular(10),
      ),
      bodyPaint,
    );
    canvas.restore();
    // Front arms
    canvas.save();
    canvas.translate(-30, -10);
    canvas.rotate(0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-7, 0, 14, 40),
        const Radius.circular(7),
      ),
      bodyPaint,
    );
    canvas.restore();
    // Back legs - improved proportions
    canvas.save();
    canvas.translate(20, -5);
    canvas.rotate(-0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-9, 0, 18, 52),
        const Radius.circular(9),
      ),
      bodyPaint,
    );
    canvas.restore();
    // Head
    canvas.drawCircle(const Offset(-38, -8), 14, bodyPaint);
  }

  // ── Mountain pose ─────────────────────────────────────────────────────────
  void _drawMountainPose(Canvas canvas) {
    final bodyPaint = Paint()..color = phaseColor.withAlpha(220);

    // Legs straight - improved proportions for better realism
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-20, 0, 16, 55),
        const Radius.circular(8),
      ),
      bodyPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(4, 0, 16, 55),
        const Radius.circular(8),
      ),
      bodyPaint,
    );
    // Torso
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-18, -70, 36, 70),
        const Radius.circular(12),
      ),
      bodyPaint,
    );
    // Arms at sides
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-30, -65, 12, 50),
        const Radius.circular(6),
      ),
      bodyPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(18, -65, 12, 50),
        const Radius.circular(6),
      ),
      bodyPaint,
    );

    _drawHead(canvas, yOffset: -88);
  }

  // -- Shared head drawing — more humanoid instructor style ----------------
  void _drawHead(Canvas canvas, {double yOffset = -76}) {
    final blink = sin(envT * pi * 2 * 0.55) > 0.965;
    final speaking = isSpeaking && instruction.trim().isNotEmpty;
    final mouthOpen = speaking ? (0.28 + lipT * 0.72) : 0.0;
    final headBob = speaking ? sin(envT * pi * 12) * 0.65 : 0.0;
    final headCenter = Offset(0, yOffset + headBob);
    final calmSmile = breathPhase == BreathPhase.complete ? 1.0 : 0.45;

    final auraPaint = Paint()
      ..color = phaseColor.withAlpha((18 * auraT).toInt())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(headCenter, 31, auraPaint);

    final neckPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFf2bd8f), Color(0xFFd99563)],
      ).createShader(Rect.fromLTWH(-9, yOffset + 14, 18, 20));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-8, yOffset + 15, 16, 16),
        const Radius.circular(5),
      ),
      neckPaint,
    );

    final earPaint = Paint()..color = const Color(0xFFe6a978);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-22, yOffset + 1), width: 8, height: 13),
      earPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(22, yOffset + 1), width: 8, height: 13),
      earPaint,
    );

    // Skin tone head
    final headPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFffe4c8),
          const Color(0xFFf2bd8f),
          const Color(0xFFb87548),
        ],
        center: const Alignment(-0.2, -0.2),
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: headCenter, radius: 21));
    canvas.drawOval(
      Rect.fromCenter(center: headCenter, width: 39, height: 44),
      headPaint,
    );

    // Lord Shiva-inspired matted hair (jata)
    final hairPaint = Paint()..color = const Color(0xFF1a120b);

    // Matted hair piled up in bun style (jata)
    final hairPath = Path()
      ..moveTo(-22, yOffset - 2)
      ..cubicTo(-20, yOffset - 25, -8, yOffset - 35, 6, yOffset - 33)
      ..cubicTo(18, yOffset - 31, 25, yOffset - 15, 22, yOffset + 4)
      ..quadraticBezierTo(15, yOffset - 2, 10, yOffset - 15)
      ..quadraticBezierTo(0, yOffset - 22, -10, yOffset - 12)
      ..quadraticBezierTo(-16, yOffset - 2, -22, yOffset - 2)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Hair bun on top (jata)
    final bunPaint = Paint()..color = const Color(0xFF2a1a10);
    final bunPath = Path()
      ..moveTo(-10, yOffset - 30)
      ..cubicTo(-14, yOffset - 42, -2, yOffset - 46, 8, yOffset - 44)
      ..cubicTo(16, yOffset - 42, 18, yOffset - 32, 14, yOffset - 28)
      ..cubicTo(10, yOffset - 26, 0, yOffset - 28, -10, yOffset - 30)
      ..close();
    canvas.drawPath(bunPath, bunPaint);

    final browPaint = Paint()
      ..color = const Color(0xFF4b2d1d)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final browLift = breathPhase == BreathPhase.inhale
        ? -1.1
        : breathPhase == BreathPhase.rest
            ? 0.9
            : 0.0;
    canvas.drawArc(
      Rect.fromLTWH(-14, yOffset - 10 + browLift, 10, 5),
      pi,
      pi,
      false,
      browPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(4, yOffset - 10 + browLift, 10, 5),
      pi,
      pi,
      false,
      browPaint,
    );

    // Eyes with subtle pupils
    final eyePaint = Paint()
      ..color = const Color(0xFF3b2619)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (blink) {
      canvas.drawLine(
        Offset(-14, yOffset - 4),
        Offset(-5, yOffset - 4),
        eyePaint,
      );
      canvas.drawLine(
        Offset(5, yOffset - 4),
        Offset(14, yOffset - 4),
        eyePaint,
      );
    } else {
      canvas.drawArc(
        Rect.fromLTWH(-14, yOffset - 7, 10, 7),
        0.05,
        pi - 0.1,
        false,
        eyePaint,
      );
      canvas.drawArc(
        Rect.fromLTWH(4, yOffset - 7, 10, 7),
        0.05,
        pi - 0.1,
        false,
        eyePaint,
      );
      canvas.drawCircle(
        Offset(-9, yOffset - 4.8),
        1.2,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(6, yOffset - 4.8),
        1.2,
        Paint()..color = Colors.white,
      );
    }

    // Nose
    final nosePaint = Paint()
      ..color = const Color(0xFF8c5736)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final nosePath = Path()
      ..moveTo(0, yOffset - 2)
      ..relativeLineTo(0, 6)
      ..relativeLineTo(-3, 3);
    canvas.drawPath(nosePath, nosePaint);

    final mouthPaint = Paint()
      ..color = const Color(0xFF5b1f1a)
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (speaking) {
      final mouthRect = Rect.fromCenter(
        center: Offset(0, yOffset + 10),
        width: 8.0 + lipT * 5.0,
        height: 2.5 + mouthOpen * 7.0,
      );
      canvas.drawOval(mouthRect, Paint()..color = const Color(0xFF4a1715));
      canvas.drawArc(
        mouthRect.inflate(0.8),
        0,
        pi,
        false,
        Paint()
          ..color = const Color(0xFFe58b86).withAlpha(155)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke,
      );
    } else {
      canvas.drawArc(
        Rect.fromLTWH(-8, yOffset + 4, 16, 8 + calmSmile * 2),
        0.08,
        pi - 0.16,
        false,
        mouthPaint,
      );
    }

    final cheekPaint = Paint()..color = const Color(0xFFf28a91).withAlpha(50);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-12, yOffset + 4), width: 7, height: 4),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(12, yOffset + 4), width: 7, height: 4),
      cheekPaint,
    );

    if (breathPhase == BreathPhase.complete) {
      final checkPaint = Paint()
        ..color = const Color(0xFF38b000)
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(-9, yOffset)
        ..lineTo(-3, yOffset + 7)
        ..lineTo(11, yOffset - 10);
      canvas.drawPath(path, checkPaint);
    }
  }

  // ── Speech bubble ─────────────────────────────────────────────────────────
  void _drawSpeechBubble(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final groundY = size.height * 0.63;

    // FIXED: Position bubble ABOVE character head (character is about 100-120px tall)
    // Character head top is approximately at groundY - 120
    // Position bubble 20px above head top
    final characterHeadTop = groundY - 120;
    final bubbleBottomY = characterHeadTop - 20;

    // FIXED: Better responsive width calculation to prevent overflow
    final bubbleW = min(size.width * 0.85, 320.0).clamp(200.0, 320.0);

    final tp = TextPainter(
      text: TextSpan(
        text: instruction,
        style: const TextStyle(
          color: Color(0xFF1a1a2e),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          height: 1.4,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 3,
      ellipsis: '...',
    )..layout(maxWidth: bubbleW - 32); // More padding to prevent text overflow

    // FIXED: Better height calculation with min/max constraints
    final bubbleH = (tp.height + 28).clamp(52.0, 120.0);

    // Center of bubble should be above the character head
    final bubbleCenterY = bubbleBottomY - bubbleH / 2;

    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, bubbleCenterY),
        width: bubbleW,
        height: bubbleH,
      ),
      const Radius.circular(20), // Slightly more rounded
    );

    // Improved gradient background
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withAlpha(250),
          Colors.white.withAlpha(235),
        ],
      ).createShader(bubbleRect.outerRect);
    canvas.drawRRect(bubbleRect, bgPaint);

    // Subtle shadow for depth
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, bubbleCenterY + 2),
          width: bubbleW,
          height: bubbleH,
        ),
        const Radius.circular(20),
      ),
      shadowPaint,
    );

    // Speech bubble tail pointing down to character
    final tailTipY = bubbleBottomY + 12;
    final tailPath = Path()
      ..moveTo(cx - 10, bubbleBottomY)
      ..lineTo(cx + 10, bubbleBottomY)
      ..lineTo(cx, tailTipY)
      ..close();
    canvas.drawPath(tailPath, bgPaint);

    // Improved border with gradient
    final borderPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          phaseColor.withAlpha(200),
          phaseColor.withAlpha(150),
        ],
      ).createShader(bubbleRect.outerRect)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(bubbleRect, borderPaint);

    // Center text properly with safety bounds
    final textX = (cx - tp.width / 2).clamp(16.0, size.width - tp.width - 16);
    final textY = bubbleCenterY - tp.height / 2;

    tp.paint(canvas, Offset(textX, textY));
  }

  @override
  bool shouldRepaint(_ScenePainter old) =>
      old.envT != envT ||
      old.bodyScale != bodyScale ||
      old.auraT != auraT ||
      old.creatureT != creatureT ||
      old.poseT != poseT ||
      old.lipT != lipT ||
      old.blinkT != blinkT ||
      old.swayT != swayT ||
      old.gestureT != gestureT ||
      old.successT != successT ||
      old.phaseColor != phaseColor ||
      old.instruction != instruction ||
      old.breathPhase != breathPhase ||
      old.environment != environment ||
      old.timeOfDay != timeOfDay ||
      old.isActive != isActive ||
      old.isSpeaking != isSpeaking ||
      old.teacher != teacher;
}

// ═══════════════════════════════════════════════════════════════════════════
// DATA CLASSES
// ═══════════════════════════════════════════════════════════════════════════

enum _ParticleType { leaf, petal, bubble, star, sand, dust, snow, rain }

enum _CreatureType { bird, eagle, butterfly, fish, bee, comet }

class _Particle {
  final double x, y, size, speed, phase, drift;
  final _ParticleType type;
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
    required this.drift,
    required this.type,
  });
}

class _Creature {
  final _CreatureType type;
  final double x, y, speed, phase, size;
  _Creature({
    required this.type,
    required this.x,
    required this.y,
    required this.speed,
    required this.phase,
    required this.size,
  });
}
