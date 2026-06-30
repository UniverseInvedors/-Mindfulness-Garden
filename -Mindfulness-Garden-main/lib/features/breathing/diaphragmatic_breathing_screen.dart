import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/app_theme.dart';
import '../../core/services/haptic_service.dart';

enum DiaphragmaticPhase {
  inhale,
  exhale,
}

class DiaphragmaticBreathingScreen extends ConsumerStatefulWidget {
  const DiaphragmaticBreathingScreen({super.key});

  @override
  ConsumerState<DiaphragmaticBreathingScreen> createState() =>
      _DiaphragmaticBreathingScreenState();
}

class _DiaphragmaticBreathingScreenState
    extends ConsumerState<DiaphragmaticBreathingScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  DiaphragmaticPhase _currentPhase = DiaphragmaticPhase.inhale;
  int _cycleCount = 0;
  final int _totalCycles = 12;
  bool _isPaused = false;
  bool _isCompleted = false;

  // Diaphragmatic breathing: 6 seconds inhale, 6 seconds exhale
  final int _inhaleDuration = 6;
  final int _exhaleDuration = 6;

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
        case DiaphragmaticPhase.inhale:
          _currentPhase = DiaphragmaticPhase.exhale;
          _breathingController.duration = Duration(seconds: _exhaleDuration);
          break;
        case DiaphragmaticPhase.exhale:
          _cycleCount++;
          if (_cycleCount >= _totalCycles) {
            _isCompleted = true;
            return;
          }
          _currentPhase = DiaphragmaticPhase.inhale;
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
      case DiaphragmaticPhase.inhale:
        return 'Inhale deeply\nBreathe into your belly';
      case DiaphragmaticPhase.exhale:
        return 'Exhale slowly\nRelease from your belly';
    }
  }

  String _getPhaseEmoji() {
    switch (_currentPhase) {
      case DiaphragmaticPhase.inhale:
        return '🌬️';
      case DiaphragmaticPhase.exhale:
        return '🍃';
    }
  }

  int _getCurrentDuration() {
    switch (_currentPhase) {
      case DiaphragmaticPhase.inhale:
        return _inhaleDuration;
      case DiaphragmaticPhase.exhale:
        return _exhaleDuration;
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
                        'Diaphragmatic Breathing',
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
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Focus on breathing from your diaphragm, not your chest. Place one hand on your belly to feel it rise and fall.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
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
                          'You completed $_totalCycles of\ndiaphragmatic breathing',
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

                        // Diaphragm visualization (belly breathing)
                        AnimatedBuilder(
                          animation: _breathingController,
                          builder: (context, child) {
                            double progress = _breathingController.value;
                            double bellySize = 100.0;
                            double chestSize = 80.0;
                            
                            if (_currentPhase == DiaphragmaticPhase.inhale) {
                              bellySize = 100.0 + (progress * 60.0);
                              chestSize = 80.0 + (progress * 10.0); // Minimal chest movement
                            } else {
                              bellySize = 160.0 - (progress * 60.0);
                              chestSize = 90.0 - (progress * 10.0);
                            }

                            return Column(
                              children: [
                                // Chest (minimal movement)
                                Container(
                                  width: chestSize,
                                  height: chestSize,
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryColor.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.secondaryColor.withOpacity(0.5),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Belly (main movement)
                                Container(
                                  width: bellySize,
                                  height: bellySize,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.primaryColor.withOpacity(0.5),
                                        AppTheme.primaryColor.withOpacity(0.2),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.4),
                                        blurRadius: 30,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Center(
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
                                ),
                                const SizedBox(height: 20),
                                // Labels
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Chest',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 40),
                                    Text(
                                      'Belly',
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
                              _currentPhase = DiaphragmaticPhase.inhale;
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
