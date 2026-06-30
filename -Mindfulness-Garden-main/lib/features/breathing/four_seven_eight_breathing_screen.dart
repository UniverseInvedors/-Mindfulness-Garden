import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/app_theme.dart';
import '../../core/services/haptic_service.dart';

enum FourSevenEightPhase {
  inhale,
  hold,
  exhale,
}

class FourSevenEightBreathingScreen extends ConsumerStatefulWidget {
  const FourSevenEightBreathingScreen({super.key});

  @override
  ConsumerState<FourSevenEightBreathingScreen> createState() =>
      _FourSevenEightBreathingScreenState();
}

class _FourSevenEightBreathingScreenState
    extends ConsumerState<FourSevenEightBreathingScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  FourSevenEightPhase _currentPhase = FourSevenEightPhase.inhale;
  int _cycleCount = 0;
  final int _totalCycles = 8;
  bool _isPaused = false;
  bool _isCompleted = false;

  // 4-7-8 breathing: 4 seconds inhale, 7 seconds hold, 8 seconds exhale
  final int _inhaleDuration = 4;
  final int _holdDuration = 7;
  final int _exhaleDuration = 8;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _inhaleDuration),
    );
    _startBreathingCycle();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  void _startBreathingCycle() {
    _breathingController.forward().then((_) {
      if (!mounted) return;
      _nextPhase();
    });
  }

  void _nextPhase() {
    setState(() {
      switch (_currentPhase) {
        case FourSevenEightPhase.inhale:
          _currentPhase = FourSevenEightPhase.hold;
          _breathingController.duration = Duration(seconds: _holdDuration);
          break;
        case FourSevenEightPhase.hold:
          _currentPhase = FourSevenEightPhase.exhale;
          _breathingController.duration = Duration(seconds: _exhaleDuration);
          break;
        case FourSevenEightPhase.exhale:
          _cycleCount++;
          if (_cycleCount >= _totalCycles) {
            _isCompleted = true;
            return;
          }
          _currentPhase = FourSevenEightPhase.inhale;
          _breathingController.duration = Duration(seconds: _inhaleDuration);
          break;
      }
    });

    if (!_isCompleted && !_isPaused) {
      _breathingController.reset();
      _breathingController.forward().then((_) {
        if (mounted) _nextPhase();
      });
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _breathingController.stop();
      } else {
        _breathingController.forward().then((_) {
          if (mounted) _nextPhase();
        });
      }
    });
    HapticService.lightImpact();
  }

  String _getPhaseInstruction() {
    switch (_currentPhase) {
      case FourSevenEightPhase.inhale:
        return 'Inhale for 4 seconds\nBreathe in deeply through your nose';
      case FourSevenEightPhase.hold:
        return 'Hold for 7 seconds\nRetain your breath calmly';
      case FourSevenEightPhase.exhale:
        return 'Exhale for 8 seconds\nRelease slowly through your mouth';
    }
  }

  String _getPhaseEmoji() {
    switch (_currentPhase) {
      case FourSevenEightPhase.inhale:
        return '🌬️';
      case FourSevenEightPhase.hold:
        return '⏸️';
      case FourSevenEightPhase.exhale:
        return '🍃';
    }
  }

  int _getCurrentDuration() {
    switch (_currentPhase) {
      case FourSevenEightPhase.inhale:
        return _inhaleDuration;
      case FourSevenEightPhase.hold:
        return _holdDuration;
      case FourSevenEightPhase.exhale:
        return _exhaleDuration;
    }
  }

  Color _getPhaseColor() {
    switch (_currentPhase) {
      case FourSevenEightPhase.inhale:
        return AppTheme.primaryColor;
      case FourSevenEightPhase.hold:
        return AppTheme.secondaryColor;
      case FourSevenEightPhase.exhale:
        return AppTheme.accentColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor.withOpacity(0.2),
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        '4-7-8 Breathing',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        '$_cycleCount/$_totalCycles',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Info card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '4',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'inhale',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '7',
                          style: TextStyle(
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'hold',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '8',
                          style: TextStyle(
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'exhale',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_isCompleted) ...[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.secondaryColor,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            size: 60,
                            color: Colors.white,
                          ),
                        )
                            .animate()
                            .scale(duration: 600.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 30),
                        Text(
                          'Session Complete!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 600.ms),
                        const SizedBox(height: 20),
                        Text(
                          'You completed $_totalCycles of\n4-7-8 breathing',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 600.ms),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () => context.pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Return to Menu'),
                        )
                            .animate()
                            .fadeIn(delay: 600.ms, duration: 600.ms),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Breathing visualization
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Phase emoji
                        Text(
                          _getPhaseEmoji(),
                          style: const TextStyle(fontSize: 80),
                        )
                            .animate()
                            .scale(
                              duration: 500.ms,
                              curve: Curves.easeInOut,
                            ),
                        const SizedBox(height: 30),

                        // Breathing circle with progress
                        AnimatedBuilder(
                          animation: _breathingController,
                          builder: (context, child) {
                            double progress = _breathingController.value;
                            double scale = 1.0;
                            
                            if (_currentPhase == FourSevenEightPhase.inhale) {
                              scale = 1.0 + (progress * 0.8);
                            } else if (_currentPhase == FourSevenEightPhase.exhale) {
                              scale = 1.8 - (progress * 0.8);
                            } else {
                              scale = 1.8;
                            }

                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      _getPhaseColor().withOpacity(0.6),
                                      _getPhaseColor().withOpacity(0.3),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getPhaseColor().withOpacity(0.4),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Progress ring
                                    Center(
                                      child: SizedBox(
                                        width: 200,
                                        height: 200,
                                        child: CircularProgressIndicator(
                                          value: progress,
                                          strokeWidth: 8,
                                          backgroundColor: Colors.white.withOpacity(0.1),
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            _getPhaseColor(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Center text
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${(progress * _getCurrentDuration()).toInt()}',
                                            style: const TextStyle(
                                              fontSize: 48,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            '${_getCurrentDuration()}s',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 40),

                        // Phase instruction
                        Text(
                          _getPhaseInstruction(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 300.ms),
                      ],
                    ),
                  ),
                ),

                // Controls
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isPaused ? Icons.play_arrow : Icons.pause,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: _togglePause,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              _cycleCount = 0;
                              _currentPhase = FourSevenEightPhase.inhale;
                              _isCompleted = false;
                              _breathingController.reset();
                              _startBreathingCycle();
                            });
                            HapticService.lightImpact();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
