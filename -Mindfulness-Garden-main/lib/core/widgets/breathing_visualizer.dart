import 'package:flutter/material.dart';
import 'package:pranaverse/core/themes/app_theme.dart';

class BreathingVisualizer extends StatefulWidget {
  final double size;
  final Color inhaleColor;
  final Color exhaleColor;

  const BreathingVisualizer({
    super.key,
    this.size = 250,
    this.inhaleColor = AppColors.secondary,
    this.exhaleColor = AppColors.tertiary,
  });

  @override
  State<BreathingVisualizer> createState() => _BreathingVisualizerState();
}

class _BreathingVisualizerState extends State<BreathingVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isInhaling = true;
  int _breathCount = 0;
  String _breathText = 'INHALE...';

  final Duration _inhaleDuration = const Duration(seconds: 4);
  final Duration _holdDuration = const Duration(seconds: 2);
  final Duration _exhaleDuration = const Duration(seconds: 6);
  final Duration _pauseDuration = const Duration(seconds: 2);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _inhaleDuration);

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _startBreathingCycle();
  }

  void _startBreathingCycle() {
    _performInhale();
  }

  void _performInhale() {
    _controller.duration = _inhaleDuration;
    _controller.forward().then((_) {
      _performHold();
    });
  }

  void _performHold() {
    Future.delayed(_holdDuration, () {
      _performExhale();
    });
  }

  void _performExhale() {
    setState(() {
      _isInhaling = false;
      _breathText = 'EXHALE...';
    });

    _controller.duration = _exhaleDuration;
    _controller.reverse().then((_) {
      _performPause();
    });
  }

  void _performPause() {
    Future.delayed(_pauseDuration, () {
      setState(() {
        _isInhaling = true;
        _breathText = 'INHALE...';
        _breathCount++;
      });
      _performInhale();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final inhaleColor = widget.inhaleColor;
    final exhaleColor = widget.exhaleColor;
    final currentColor = _isInhaling ? inhaleColor : exhaleColor;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Column(
                children: [
                  // Breath instruction
                  Text(
                    _breathText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: currentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Breathing animation container
                  Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulsing background
                        Container(
                          width: widget.size * 0.9,
                          height: widget.size * 0.9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                currentColor.withAlpha(40),
                                Colors.transparent,
                              ],
                              stops: const [0.5, 1.0],
                            ),
                          ),
                        ),

                        // Breathing circle
                        Container(
                          width: 80 + (_animation.value * 100),
                          height: 80 + (_animation.value * 100),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                currentColor.withAlpha(100),
                                currentColor.withAlpha(40),
                              ],
                            ),
                            border: Border.all(
                              color: currentColor.withAlpha(150),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: currentColor.withAlpha(60),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              _isInhaling ? Icons.air : Icons.water_drop,
                              size: 40,
                              color: currentColor,
                            ),
                          ),
                        ),

                        // Breath counter
                        Positioned(
                          bottom: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.outlineVariant),
                            ),
                            child: Text(
                              '$_breathCount',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colors.onSurface,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // Breathing pattern info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  '4-2-6-2 PATTERN',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBreathPhase('Inhale', '4s', inhaleColor),
                    _buildBreathPhase('Hold', '2s', colors.primary),
                    _buildBreathPhase('Exhale', '6s', exhaleColor),
                    _buildBreathPhase('Pause', '2s', colors.outline),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreathPhase(String label, String duration, Color color) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withAlpha(40),
            shape: BoxShape.circle,
            border: Border.all(color: color.withAlpha(100)),
          ),
          child: Center(
            child: Text(
              duration.substring(0, 1),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
