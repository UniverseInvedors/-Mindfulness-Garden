import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/app_theme.dart';
import '../../core/services/haptic_service.dart';

enum BreathingPhase {
  inhaleLeft,
  holdLeft,
  exhaleRight,
  inhaleRight,
  holdRight,
  exhaleLeft,
}

class AlternateNostrilScreen extends ConsumerStatefulWidget {
  const AlternateNostrilScreen({super.key});

  @override
  ConsumerState<AlternateNostrilScreen> createState() =>
      _AlternateNostrilScreenState();
}

class _AlternateNostrilScreenState
    extends ConsumerState<AlternateNostrilScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  BreathingPhase _currentPhase = BreathingPhase.inhaleLeft;
  int _cycleCount = 0;
  final int _totalCycles = 10;
  bool _isPaused = false;
  bool _isCompleted = false;

  // Timing for each phase (in seconds)
  final int _inhaleDuration = 4;
  final int _holdDuration = 4;
  final int _exhaleDuration = 4;

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
        case BreathingPhase.inhaleLeft:
          _currentPhase = BreathingPhase.holdLeft;
          _breathingController.duration = Duration(seconds: _holdDuration);
          break;
        case BreathingPhase.holdLeft:
          _currentPhase = BreathingPhase.exhaleRight;
          _breathingController.duration = Duration(seconds: _exhaleDuration);
          break;
        case BreathingPhase.exhaleRight:
          _currentPhase = BreathingPhase.inhaleRight;
          _breathingController.duration = Duration(seconds: _inhaleDuration);
          break;
        case BreathingPhase.inhaleRight:
          _currentPhase = BreathingPhase.holdRight;
          _breathingController.duration = Duration(seconds: _holdDuration);
          break;
        case BreathingPhase.holdRight:
          _currentPhase = BreathingPhase.exhaleLeft;
          _breathingController.duration = Duration(seconds: _exhaleDuration);
          break;
        case BreathingPhase.exhaleLeft:
          _cycleCount++;
          if (_cycleCount >= _totalCycles) {
            _isCompleted = true;
            return;
          }
          _currentPhase = BreathingPhase.inhaleLeft;
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
      case BreathingPhase.inhaleLeft:
        return 'Close right nostril\nInhale through left';
      case BreathingPhase.holdLeft:
        return 'Hold both nostrils\nRetain breath';
      case BreathingPhase.exhaleRight:
        return 'Close left nostril\nExhale through right';
      case BreathingPhase.inhaleRight:
        return 'Close left nostril\nInhale through right';
      case BreathingPhase.holdRight:
        return 'Hold both nostrils\nRetain breath';
      case BreathingPhase.exhaleLeft:
        return 'Close right nostril\nExhale through left';
    }
  }

  String _getPhaseEmoji() {
    switch (_currentPhase) {
      case BreathingPhase.inhaleLeft:
      case BreathingPhase.inhaleRight:
        return '🌬️';
      case BreathingPhase.holdLeft:
      case BreathingPhase.holdRight:
        return '⏸️';
      case BreathingPhase.exhaleLeft:
      case BreathingPhase.exhaleRight:
        return '🍃';
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
                        'Alternate Nostril Breathing',
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
                          'You completed $_totalCycles of\nalternate nostril breathing',
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

                        // Breathing circle
                        AnimatedBuilder(
                          animation: _breathingController,
                          builder: (context, child) {
                            double scale = 1.0;
                            if (_currentPhase ==
                                    BreathingPhase.inhaleLeft ||
                                _currentPhase ==
                                    BreathingPhase.inhaleRight) {
                              scale = 1.0 + (_breathingController.value * 0.5);
                            } else if (_currentPhase ==
                                    BreathingPhase.exhaleLeft ||
                                _currentPhase ==
                                    BreathingPhase.exhaleRight) {
                              scale = 1.5 - (_breathingController.value * 0.5);
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
                                      AppTheme.primaryColor.withOpacity(0.6),
                                      AppTheme.secondaryColor.withOpacity(0.6),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withOpacity(0.4),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '${(_breathingController.value * 100).toInt()}%',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
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
                            fontSize: 24,
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
                              _currentPhase = BreathingPhase.inhaleLeft;
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
