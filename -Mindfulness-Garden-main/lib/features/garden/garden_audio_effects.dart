import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../services/audio_manager_service.dart';
import '../../services/audio_constants.dart';

/// Garden-specific audio and visual effects manager
class GardenAudioEffects {
  final AudioManagerService _audioManager = AudioManagerService();

  // Confetti controllers for celebrations
  final List<ConfettiController> _confettiControllers = [];

  /// Initialize audio for the garden
  Future<void> initialize() async {
    await _audioManager.initialize();
    // Start with day ambience
    await _audioManager.setGardenAmbience(true);
  }

  /// Play sound when planting a seed
  Future<void> playPlantSound() async {
    await _audioManager.playPlantSound();
  }

  /// Play sound when watering plants
  Future<void> playWaterSound() async {
    await _audioManager.playWaterSound();
  }

  /// Play sound when harvesting
  Future<void> playHarvestSound() async {
    await _audioManager.playHarvestSound();
    await _audioManager.playSparkleSound();
  }

  /// Play sound when plant grows to next stage
  Future<void> playGrowthSound() async {
    await _audioManager.playSparkleSound();
  }

  /// Play sound when adding decoration
  Future<void> playDecorationSound() async {
    await _audioManager.playSfx(AudioConstants.uiSelect2);
  }

  /// Play sound when adding NPC
  Future<void> playNPCSound(String npcType) async {
    switch (npcType.toLowerCase()) {
      case 'butterfly':
        await _audioManager.playSfx(AudioConstants.natureBirdChirp);
        break;
      case 'bird':
        await _audioManager.playSfx(AudioConstants.natureBirds);
        break;
      case 'rabbit':
      case 'turtle':
      case 'gardener':
        await _audioManager.playSuccess();
        break;
      default:
        await _audioManager.playSparkleSound();
    }
  }

  /// Change theme with appropriate music and ambience
  Future<void> changeTheme(String theme) async {
    await _audioManager.changeTheme(theme);
  }

  /// Set day/night ambience
  Future<void> setDayNightAmbience(bool isDay) async {
    await _audioManager.setGardenAmbience(isDay);
  }

  /// Play weather-appropriate sounds
  Future<void> playWeatherSound(String weather) async {
    switch (weather.toLowerCase()) {
      case 'rainy':
      case 'rain':
        await _audioManager.playAmbience(AudioConstants.natureRain);
        break;
      case 'stormy':
        await _audioManager.playAmbience(AudioConstants.natureWind);
        break;
      case 'sunny':
        await _audioManager.playAmbience(AudioConstants.natureBirds);
        break;
      case 'snowy':
        await _audioManager.playAmbience(AudioConstants.natureWind);
        break;
      case 'cloudy':
        await _audioManager.playAmbience(AudioConstants.natureForest);
        break;
      default:
        await _audioManager.setGardenAmbience(true);
    }
  }

  /// Play achievement unlock sound with celebration
  Future<void> playAchievementSound() async {
    await _audioManager.playBonusSound();
    await Future.delayed(const Duration(milliseconds: 200));
    await _audioManager.playSparkleSound();
  }

  /// Play level up sound
  Future<void> playLevelUpSound() async {
    await _audioManager.playSuccess();
    await Future.delayed(const Duration(milliseconds: 150));
    await _audioManager.playBonusSound();
  }

  /// Play error or warning sound
  Future<void> playErrorSound() async {
    await _audioManager.playError();
  }

  /// Play button click sound
  Future<void> playButtonClick() async {
    await _audioManager.playButtonClick();
  }

  /// Play meditation bell for zen moment
  Future<void> playMeditationBell() async {
    await _audioManager.playMeditationBell();
  }

  /// Play singing bowl for relaxation
  Future<void> playSingingBowl() async {
    await _audioManager.playSingingBowl();
  }

  /// Create confetti controller for celebrations
  ConfettiController createConfettiController() {
    final controller = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _confettiControllers.add(controller);
    return controller;
  }

  /// Trigger confetti celebration
  void celebrate(ConfettiController controller) {
    controller.play();
  }

  /// Dispose all controllers
  void dispose() {
    for (var controller in _confettiControllers) {
      controller.dispose();
    }
    _confettiControllers.clear();
  }
}

/// Particle effect for magical sparkles
class SparkleParticle {
  final Offset position;
  final Color color;
  final double size;
  final double velocity;
  double opacity;
  double life;

  SparkleParticle({
    required this.position,
    required this.color,
    this.size = 4.0,
    this.velocity = 2.0,
    this.opacity = 1.0,
    this.life = 1.0,
  });

  bool get isDead => life <= 0;

  void update(double dt) {
    life -= dt * 0.5;
    opacity = life;
  }
}

/// Floating text effect for notifications
class FloatingTextEffect extends StatefulWidget {
  final String text;
  final Color color;
  final double fontSize;

  const FloatingTextEffect({
    super.key,
    required this.text,
    this.color = Colors.white,
    this.fontSize = 24,
  });

  @override
  State<FloatingTextEffect> createState() => _FloatingTextEffectState();
}

class _FloatingTextEffectState extends State<FloatingTextEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _positionAnimation = Tween<double>(
      begin: 0.0,
      end: -100.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    ));

    _controller.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _positionAnimation.value),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                widget.text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Ripple effect for interactions
class RippleEffect extends StatefulWidget {
  final Offset position;
  final Color color;
  final double maxRadius;

  const RippleEffect({
    super.key,
    required this.position,
    this.color = Colors.blue,
    this.maxRadius = 100.0,
  });

  @override
  State<RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _radiusAnimation = Tween<double>(
      begin: 0.0,
      end: widget.maxRadius,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _RipplePainter(
            position: widget.position,
            radius: _radiusAnimation.value,
            color: widget.color.withValues(alpha: _opacityAnimation.value),
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _RipplePainter extends CustomPainter {
  final Offset position;
  final double radius;
  final Color color;

  _RipplePainter({
    required this.position,
    required this.radius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(position, radius, paint);
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.color != color;
  }
}
