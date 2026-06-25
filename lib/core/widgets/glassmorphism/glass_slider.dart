import 'package:flutter/material.dart';

class GlassSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? blur;
  final double? opacity;
  final Color? borderColor;
  final double? borderWidth;
  final Gradient? gradient;

  const GlassSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
    this.blur,
    this.opacity,
    this.borderColor,
    this.borderWidth,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(opacity ?? 0.1),
                Colors.white.withOpacity((opacity ?? 0.1) * 0.5),
              ],
            ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.2),
          width: borderWidth ?? 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur ?? 10, sigmaY: blur ?? 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    label!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                  activeTrackColor: activeColor ?? Colors.white,
                  inactiveTrackColor: inactiveColor ?? Colors.white.withOpacity(0.3),
                  thumbColor: activeColor ?? Colors.white,
                  overlayColor: (activeColor ?? Colors.white).withOpacity(0.2),
                ),
                child: Slider(
                  value: value,
                  onChanged: onChanged,
                  min: min,
                  max: max,
                  divisions: divisions,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
