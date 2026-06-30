import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/sound_service.dart';

class GlassIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? iconColor;
  final double? blur;
  final double? opacity;
  final Color? borderColor;
  final double? borderWidth;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final bool isCircular;

  const GlassIcon({
    super.key,
    required this.icon,
    this.size,
    this.iconColor,
    this.blur,
    this.opacity,
    this.borderColor,
    this.borderWidth,
    this.gradient,
    this.onTap,
    this.isCircular = true,
  });

  @override
  Widget build(BuildContext context) {
    final iconContainer = Container(
      width: size ?? 48,
      height: size ?? 48,
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(opacity ?? 0.15),
                Colors.white.withOpacity((opacity ?? 0.15) * 0.6),
              ],
            ),
        borderRadius: isCircular ? null : BorderRadius.circular(12),
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.25),
          width: borderWidth ?? 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: isCircular
            ? BorderRadius.circular((size ?? 48) / 2)
            : BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur ?? 10, sigmaY: blur ?? 10),
          child: Icon(
            icon,
            size: (size ?? 48) * 0.5,
            color: iconColor ?? Colors.white,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: () {
          // Play click sound before executing action
          SoundService().playButtonClick();
          onTap!();
        },
        child: iconContainer,
      );
    }

    return iconContainer;
  }
}
