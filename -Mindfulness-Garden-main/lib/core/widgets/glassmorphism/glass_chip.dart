import 'package:flutter/material.dart';

class GlassChip extends StatelessWidget {
  final Widget label;
  final Widget? avatar;
  final VoidCallback? onDelete;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? blur;
  final double? opacity;
  final Color? borderColor;
  final double? borderWidth;
  final Gradient? gradient;
  final bool isSelected;

  const GlassChip({
    super.key,
    required this.label,
    this.avatar,
    this.onDelete,
    this.onPressed,
    this.padding,
    this.borderRadius,
    this.blur,
    this.opacity,
    this.borderColor,
    this.borderWidth,
    this.gradient,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.5),
                    ]
                  : [
                      Colors.white.withOpacity(opacity ?? 0.1),
                      Colors.white.withOpacity((opacity ?? 0.1) * 0.5),
                    ],
            ),
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(isSelected ? 0.4 : 0.2),
          width: borderWidth ?? 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur ?? 10, sigmaY: blur ?? 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (avatar != null) ...[
                avatar!,
                const SizedBox(width: 8),
              ],
              label,
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (onPressed != null) {
      return GestureDetector(
        onTap: onPressed,
        child: chip,
      );
    }

    return chip;
  }
}
