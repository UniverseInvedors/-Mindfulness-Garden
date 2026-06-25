import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:pranaverse/core/utils/responsive_helper.dart';
import 'package:pranaverse/core/widgets/glassmorphism/glass_button.dart';
import 'package:pranaverse/core/widgets/glassmorphism/glass_card.dart';
import 'package:pranaverse/core/widgets/glassmorphism/glass_container.dart';
import 'package:pranaverse/core/widgets/glassmorphism/glass_icon.dart';
import '../../core/services/haptic_service.dart';

enum BoxPhase {
  inhale,
  hold,
  exhale,
  holdAfterExhale,
}

class BoxBreathingScreen extends ConsumerStatefulWidget {
  const BoxBreathingScreen({super.key});

  @override
  ConsumerState<BoxBreathingScreen> createState() =>
      _BoxBreathingScreenState();
}

class _BoxBreathingScreenState extends ConsumerState<BoxBreathingScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  BoxPhase _currentPhase = BoxPhase.inhale;
  int _cycleCount = 0;
  final int _totalCycles = 10;
  bool _isPaused = false;
  bool _isCompleted = false;

  // Box breathing uses equal timing for all phases (4 seconds each)
  final int _phaseDuration = 4;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _phaseDuration),
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
        case BoxPhase.inhale:
          _currentPhase = BoxPhase.hold;
          break;
        case BoxPhase.hold:
          _currentPhase = BoxPhase.exhale;
          break;
        case BoxPhase.exhale:
          _currentPhase = BoxPhase.holdAfterExhale;
          break;
        case BoxPhase.holdAfterExhale:
          _cycleCount++;
          if (_cycleCount >= _totalCycles) {
            _isCompleted = true;
            return;
          }
          _currentPhase = BoxPhase.inhale;
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
      case BoxPhase.inhale:
        return 'Inhale\nBreathe in deeply';
      case BoxPhase.hold:
        return 'Hold\nRetain your breath';
      case BoxPhase.exhale:
        return 'Exhale\nRelease slowly';
      case BoxPhase.holdAfterExhale:
        return 'Hold\nWait before next breath';
    }
  }

  String _getPhaseEmoji() {
    switch (_currentPhase) {
      case BoxPhase.inhale:
        return '🌬️';
      case BoxPhase.hold:
        return '⏸️';
      case BoxPhase.exhale:
        return '🍃';
      case BoxPhase.holdAfterExhale:
        return '🧘';
    }
  }

  Color _getPhaseColor() {
    switch (_currentPhase) {
      case BoxPhase.inhale:
        return const Color(0xFF4CAF50);
      case BoxPhase.hold:
        return const Color(0xFF81C784);
      case BoxPhase.exhale:
        return const Color(0xFF66BB6A);
      case BoxPhase.holdAfterExhale:
        return const Color(0xFFA5D6A7);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D2B1E), Color(0xFF0A1F15), Color(0xFF071810)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, mobilePadding: 20)),
                child: Row(
                  children: [
                    GlassIcon(
                      icon: Icons.arrow_back,
                      onTap: () => context.pop(),
                      size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 24, tabletSize: 26, desktopSize: 28),
                      iconColor: Colors.white,
                      blur: 10,
                      opacity: 0.1,
                    ),
                    SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 20)),
                    Expanded(
                      child: Text(
                        'Box Breathing',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 20, tabletSize: 22, desktopSize: 24),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GlassCard(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 16),
                        vertical: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 8),
                      ),
                      borderRadius: BorderRadius.circular(20),
                      blur: 8,
                      opacity: 0.1,
                      child: Text(
                        '$_cycleCount/$_totalCycles',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 14, tabletSize: 15, desktopSize: 16),
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
                        GlassContainer(
                          width: ResponsiveHelper.getResponsiveContainerWidth(context, mobileWidth: 120),
                          height: ResponsiveHelper.getResponsiveContainerHeight(context, mobileHeight: 120),
                          borderRadius: BorderRadius.circular(60),
                          blur: 20,
                          opacity: 0.2,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF4CAF50),
                              Color(0xFF81C784),
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
                        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 30)),
                        Text(
                          'Session Complete!',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 28, tabletSize: 30, desktopSize: 32),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 600.ms),
                        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 20)),
                        Text(
                          'You completed $_totalCycles of\nbox breathing',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 16, tabletSize: 17, desktopSize: 18),
                            color: Colors.white.withOpacity(0.8),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 600.ms),
                        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 40)),
                        GlassButton(
                          onPressed: () => context.pop(),
                          blur: 12,
                          opacity: 0.2,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          child: Text('Return to Menu',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 16, tabletSize: 17, desktopSize: 18),
                                fontWeight: FontWeight.w600,
                              )),
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
                        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 30)),

                        // Box breathing visualization
                        SizedBox(
                          width: ResponsiveHelper.getResponsiveContainerWidth(context, mobileWidth: 250),
                          height: ResponsiveHelper.getResponsiveContainerHeight(context, mobileHeight: 250),
                          child: AnimatedBuilder(
                            animation: _breathingController,
                            builder: (context, child) {
                              double progress = _breathingController.value;
                              double size = 100.0;
                              
                              if (_currentPhase == BoxPhase.inhale) {
                                size = 100.0 + (progress * 100.0);
                              } else if (_currentPhase == BoxPhase.exhale) {
                                size = 200.0 - (progress * 100.0);
                              } else if (_currentPhase == BoxPhase.hold) {
                                size = 200.0;
                              } else {
                                size = 100.0;
                              }

                              return Center(
                                child: GlassContainer(
                                  width: size,
                                  height: size,
                                  borderRadius: BorderRadius.circular(20),
                                  blur: 20,
                                  opacity: 0.3,
                                  gradient: LinearGradient(
                                    colors: [
                                      _getPhaseColor().withOpacity(0.3),
                                      _getPhaseColor().withOpacity(0.15),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${(progress * 100).toInt()}%',
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 32, tabletSize: 34, desktopSize: 36),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 40)),

                        // Phase instruction
                        Text(
                          _getPhaseInstruction(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 24, tabletSize: 26, desktopSize: 28),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 300.ms),

                        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 20)),

                        // Phase indicator (box pattern)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildPhaseIndicator(context, 'Inhale', BoxPhase.inhale),
                            _buildPhaseIndicator(context, 'Hold', BoxPhase.hold),
                            _buildPhaseIndicator(context, 'Exhale', BoxPhase.exhale),
                            _buildPhaseIndicator(context, 'Hold', BoxPhase.holdAfterExhale),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Controls
                Padding(
                  padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, mobilePadding: 30)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GlassIcon(
                        icon: _isPaused ? Icons.play_arrow : Icons.pause,
                        onTap: _togglePause,
                        size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 32, tabletSize: 34, desktopSize: 36),
                        iconColor: Colors.white,
                        blur: 10,
                        opacity: 0.1,
                        isCircular: true,
                      ),
                      GlassIcon(
                        icon: Icons.refresh,
                        onTap: () {
                          setState(() {
                            _cycleCount = 0;
                            _currentPhase = BoxPhase.inhale;
                            _isCompleted = false;
                            _breathingController.reset();
                            _startBreathingCycle();
                          });
                          HapticService.lightImpact();
                        },
                        size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 32, tabletSize: 34, desktopSize: 36),
                        iconColor: Colors.white,
                        blur: 10,
                        opacity: 0.1,
                        isCircular: true,
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

  Widget _buildPhaseIndicator(BuildContext context, String label, BoxPhase phase) {
    bool isActive = _currentPhase == phase;
    return GlassCard(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 8)),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 12),
        vertical: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 8),
      ),
      borderRadius: BorderRadius.circular(12),
      blur: isActive ? 10 : 6,
      opacity: isActive ? 0.3 : 0.1,
      gradient: LinearGradient(
        colors: isActive
            ? [_getPhaseColor().withOpacity(0.3), _getPhaseColor().withOpacity(0.15)]
            : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? _getPhaseColor() : Colors.white.withOpacity(0.6),
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 12, tabletSize: 13, desktopSize: 14),
        ),
      ),
    );
  }
}
