import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/app_theme.dart';
import '../../core/services/haptic_service.dart';

class BreathAwarenessScreen extends ConsumerStatefulWidget {
  const BreathAwarenessScreen({super.key});

  @override
  ConsumerState<BreathAwarenessScreen> createState() =>
      _BreathAwarenessScreenState();
}

class _BreathAwarenessScreenState extends ConsumerState<BreathAwarenessScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  int _cycleCount = 0;
  final int _totalCycles = 15;
  bool _isPaused = false;
  bool _isCompleted = false;
  bool _isInhaling = true;

  // Breath awareness: natural breathing, focus on awareness rather than timing
  final int _cycleDuration = 8; // Average natural breath cycle

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _cycleDuration),
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
      _isInhaling = !_isInhaling;
      if (!_isInhaling) {
        _cycleCount++;
        if (_cycleCount >= _totalCycles) {
          _isCompleted = true;
          return;
        }
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
    return _isInhaling
        ? 'Observe your breath\nNotice the inhalation'
        : 'Observe your breath\nNotice the exhalation';
  }

  String _getPhaseEmoji() {
    return _isInhaling ? '🌬️' : '🍃';
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
                        'Breath Awareness',
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
                          'Simply observe your natural breath without trying to control it. Notice the sensations as air enters and leaves your body.',
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
                          'You completed $_totalCycles of\nbreath awareness',
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

                        // Breath awareness visualization (gentle wave pattern)
                        AnimatedBuilder(
                          animation: _breathingController,
                          builder: (context, child) {
                            double progress = _breathingController.value;
                            
                            return Column(
                              children: [
                                // Multiple gentle waves representing natural breath
                                ...List.generate(5, (index) {
                                  double offset = index * 0.2;
                                  double waveProgress = (progress + offset) % 1.0;
                                  double size = 100.0 + (waveProgress * 80.0);
                                  double opacity = 0.6 - (index * 0.1);
                                  
                                  return Transform.scale(
                                    scale: size / 100.0,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      margin: EdgeInsets.only(bottom: index == 4 ? 0 : -20),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppTheme.primaryColor.withOpacity(opacity * 0.3),
                                        border: Border.all(
                                          color: AppTheme.primaryColor.withOpacity(opacity),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
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

                        const SizedBox(height: 20),

                        // Awareness tips
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Text(
                            'Notice the cool sensation as air enters\nFeel the warmth as air leaves\nObserve without judgment',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ),
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
      ),
    );
  }
}
