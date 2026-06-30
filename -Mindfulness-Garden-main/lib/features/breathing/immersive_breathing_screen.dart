import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/app_theme.dart';
import '../../core/services/haptic_service.dart';
import '../../core/widgets/particle_background.dart';

class ImmersiveBreathingScreen extends ConsumerStatefulWidget {
  const ImmersiveBreathingScreen({super.key});

  @override
  ConsumerState<ImmersiveBreathingScreen> createState() =>
      _ImmersiveBreathingScreenState();
}

class _ImmersiveBreathingScreenState extends ConsumerState<ImmersiveBreathingScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _particleController;
  late AnimationController _auraController;
  
  int _cycleCount = 0;
  final int _totalCycles = 8;
  bool _isPaused = false;
  bool _isCompleted = false;
  bool _isInhaling = true;

  final int _inhaleDuration = 6;
  final int _exhaleDuration = 6;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _inhaleDuration),
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _startBreathingCycle();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _particleController.dispose();
    _auraController.dispose();
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
      _isInhaling = !_isInhaling;
      if (!_isInhaling) {
        _cycleCount++;
        if (_cycleCount >= _totalCycles) {
          _isCompleted = true;
          return;
        }
      }
      _breathingController.duration = Duration(
        seconds: _isInhaling ? _inhaleDuration : _exhaleDuration,
      );
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
        _particleController.stop();
        _auraController.stop();
      } else {
        _breathingController.forward().then((_) {
          if (mounted) _nextPhase();
        });
        _particleController.repeat();
        _auraController.repeat();
      }
    });
    HapticService.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              AppTheme.primaryColor.withOpacity(0.3),
              AppTheme.secondaryColor.withOpacity(0.2),
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Particle background
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return ParticleBackground(
                  controller: _particleController,
                  particleCount: 50,
                );
              },
            ),

            SafeArea(
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
                            'Immersive Breathing',
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
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryColor,
                                    AppTheme.secondaryColor,
                                    AppTheme.accentColor,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withOpacity(0.6),
                                    blurRadius: 50,
                                    spreadRadius: 20,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.self_improvement,
                                size: 80,
                                color: Colors.white,
                              ),
                            )
                                .animate()
                                .scale(duration: 800.ms, curve: Curves.easeOutBack),
                            const SizedBox(height: 40),
                            Text(
                              'Session Complete',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                                .animate()
                                .fadeIn(delay: 200.ms, duration: 600.ms),
                            const SizedBox(height: 20),
                            Text(
                              'You completed $_totalCycles cycles\nof immersive breathing',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            )
                                .animate()
                                .fadeIn(delay: 400.ms, duration: 600.ms),
                            const SizedBox(height: 50),
                            ElevatedButton(
                              onPressed: () => context.pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 48,
                                  vertical: 18,
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
                    // Immersive breathing visualization
                    Expanded(
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer aura rings
                            ...List.generate(5, (index) {
                              return AnimatedBuilder(
                                animation: _auraController,
                                builder: (context, child) {
                                  double progress = (_auraController.value + index * 0.2) % 1.0;
                                  double size = 200.0 + (progress * 200.0);
                                  double opacity = 0.4 - (index * 0.08);
                                  
                                  return Container(
                                    width: size,
                                    height: size,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppTheme.primaryColor.withOpacity(opacity),
                                        width: 2,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),

                            // Main breathing circle
                            AnimatedBuilder(
                              animation: _breathingController,
                              builder: (context, child) {
                                double progress = _breathingController.value;
                                double scale = _isInhaling
                                    ? 1.0 + (progress * 1.5)
                                    : 2.5 - (progress * 1.5);
                                double opacity = _isInhaling
                                    ? 0.6 + (progress * 0.4)
                                    : 1.0 - (progress * 0.4);

                                return Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      gradient: RadialGradient(
                                        colors: [
                                          AppTheme.primaryColor.withOpacity(opacity),
                                          AppTheme.secondaryColor.withOpacity(opacity * 0.5),
                                          Colors.transparent,
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryColor.withOpacity(0.5),
                                          blurRadius: 60,
                                          spreadRadius: 20,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _isInhaling ? Icons.expand : Icons.compress,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _isInhaling ? 'Inhale' : 'Exhale',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Center focus point
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Guided text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      child: AnimatedBuilder(
                        animation: _breathingController,
                        builder: (context, child) {
                          double progress = _breathingController.value;
                          return Opacity(
                            opacity: 0.6 + (progress * 0.4),
                            child: Text(
                              _isInhaling
                                  ? 'Breathe in deeply and fully\nFeel the energy entering your body'
                                  : 'Release slowly and completely\nLet go of all tension',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                height: 1.6,
                              ),
                            ),
                          );
                        },
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
                                size: 36,
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
                                size: 36,
                              ),
                              onPressed: () {
                                setState(() {
                                  _cycleCount = 0;
                                  _isInhaling = true;
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
          ],
        ),
      ),
    );
  }
}
