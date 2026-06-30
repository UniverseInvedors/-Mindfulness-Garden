import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/audio_manager_service.dart';
import '../../../services/audio_constants.dart';
import '../widgets/celebration_effects.dart';
import '../garden_audio_effects.dart';

/// Helper class for triggering garden effects easily
class GardenEffectsHelper {
  static final AudioManagerService _audio = AudioManagerService();

  /// Show planting effect with sound and visuals
  static Future<void> showPlantEffect(
    BuildContext context, {
    Offset? position,
  }) async {
    // Play sound
    await _audio.playPlantSound();
    await Future.delayed(const Duration(milliseconds: 100));
    await _audio.playSparkleSound();

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Show sparkles
    if (context.mounted) {
      showDialog(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: false,
        builder: (context) => SparkleOverlay(
          position: position ?? const Offset(200, 200),
          color: Colors.green,
          particleCount: 25,
        ),
      );
    }
  }

  /// Show watering effect
  static Future<void> showWaterEffect(
    BuildContext context, {
    Offset? position,
  }) async {
    await _audio.playWaterSound();
    HapticFeedback.lightImpact();

    if (context.mounted) {
      showDialog(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: false,
        builder: (context) => SparkleOverlay(
          position: position ?? const Offset(200, 200),
          color: Colors.blue,
          particleCount: 30,
        ),
      );
    }
  }

  /// Show harvest effect with celebration
  static Future<void> showHarvestEffect(
    BuildContext context, {
    int coins = 0,
    int xp = 0,
  }) async {
    // Play sounds
    await _audio.playHarvestSound();
    await Future.delayed(const Duration(milliseconds: 150));
    await _audio.playSuccess();
    await Future.delayed(const Duration(milliseconds: 150));
    await _audio.playBonusSound();

    // Strong haptic
    HapticFeedback.heavyImpact();

    if (!context.mounted) return;

    // Show floating rewards
    if (coins > 0) {
      showDialog(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: false,
        builder: (context) => Center(
          child: FloatingReward(
            text: '+$coins',
            color: Colors.amber,
            icon: Icons.monetization_on,
          ),
        ),
      );
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (context.mounted && xp > 0) {
      showDialog(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: false,
        builder: (context) => Center(
          child: FloatingReward(
            text: '+$xp XP',
            color: Colors.purple,
            icon: Icons.stars,
          ),
        ),
      );
    }
  }

  /// Show growth stage animation
  static Future<void> showGrowthEffect(
    BuildContext context, {
    Offset? position,
  }) async {
    await _audio.playSparkleSound();
    HapticFeedback.lightImpact();

    if (context.mounted) {
      showDialog(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: false,
        builder: (context) => SparkleOverlay(
          position: position ?? const Offset(200, 200),
          color: Colors.yellow,
          particleCount: 20,
        ),
      );
    }
  }

  /// Show achievement unlock celebration
  static Future<void> showAchievementEffect(
    BuildContext context,
    String title,
    String description,
    int reward,
  ) async {
    // Play achievement sounds
    await _audio.playBonusSound();
    await Future.delayed(const Duration(milliseconds: 200));
    await _audio.playSuccess();
    await Future.delayed(const Duration(milliseconds: 200));
    await _audio.playSparkleSound();

    // Heavy haptic
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.heavyImpact();

    if (!context.mounted) return;

    // Show achievement dialog with confetti
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AchievementDialog(
        title: title,
        description: description,
        reward: reward,
      ),
    );
  }

  /// Show level up effect
  static Future<void> showLevelUpEffect(
    BuildContext context,
    int newLevel,
  ) async {
    await _audio.playSuccess();
    await Future.delayed(const Duration(milliseconds: 150));
    await _audio.playBonusSound();
    await Future.delayed(const Duration(milliseconds: 150));
    await _audio.playSparkleSound();

    HapticFeedback.heavyImpact();

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _LevelUpDialog(level: newLevel),
    );
  }

  /// Show error feedback
  static Future<void> showErrorEffect(
    BuildContext context,
    String message,
  ) async {
    await _audio.playError();
    HapticFeedback.vibrate();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Show success message
  static Future<void> showSuccessMessage(
    BuildContext context,
    String message,
  ) async {
    await _audio.playSuccess();
    HapticFeedback.lightImpact();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Play meditation bell
  static Future<void> playMeditationBell() async {
    await _audio.playMeditationBell();
    HapticFeedback.mediumImpact();
  }

  /// Play singing bowl
  static Future<void> playSingingBowl() async {
    await _audio.playSingingBowl();
    HapticFeedback.mediumImpact();
  }
}

/// Achievement unlock dialog
class _AchievementDialog extends StatefulWidget {
  final String title;
  final String description;
  final int reward;

  const _AchievementDialog({
    required this.title,
    required this.description,
    required this.reward,
  });

  @override
  State<_AchievementDialog> createState() => _AchievementDialogState();
}

class _AchievementDialogState extends State<_AchievementDialog> {
  bool _showConfetti = true;

  @override
  Widget build(BuildContext context) {
    return CelebrationOverlay(
      showCelebration: _showConfetti,
      onCelebrationComplete: () {
        setState(() => _showConfetti = false);
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.purple.withValues(alpha: 0.9),
                Colors.blue.withValues(alpha: 0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events,
                size: 80,
                color: Colors.yellow,
              ),
              const SizedBox(height: 16),
              const Text(
                '🎉 Achievement Unlocked! 🎉',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      '+${widget.reward} coins',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Awesome!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Level up dialog
class _LevelUpDialog extends StatefulWidget {
  final int level;

  const _LevelUpDialog({required this.level});

  @override
  State<_LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<_LevelUpDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _showConfetti = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CelebrationOverlay(
      showCelebration: _showConfetti,
      onCelebrationComplete: () {
        setState(() => _showConfetti = false);
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.withValues(alpha: 0.9),
                  Colors.pink.withValues(alpha: 0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.5),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_upward,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  '⬆️ LEVEL UP! ⬆️',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Level ${widget.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'re becoming a Garden Master!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
