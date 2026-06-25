import 'dart:ui';
import 'package:flutter/material.dart';

class GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? blur;
  final double? opacity;
  final Color? borderColor;
  final double? borderWidth;
  final Gradient? gradient;
  final Color? backgroundColor;
  final bool isFilled;

  const GlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.blur,
    this.opacity,
    this.borderColor,
    this.borderWidth,
    this.gradient,
    this.backgroundColor,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isFilled
                  ? [
                      backgroundColor ?? Colors.white.withOpacity(0.2),
                      backgroundColor?.withOpacity(0.4) ?? Colors.white.withOpacity(0.1),
                    ]
                  : [
                      Colors.white.withOpacity(opacity ?? 0.1),
                      Colors.white.withOpacity((opacity ?? 0.1) * 0.5),
                    ],
            ),
        borderRadius: borderRadius ?? BorderRadius.circular(30),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.3),
          width: borderWidth ?? 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur ?? 10, sigmaY: blur ?? 10),
          child: Center(
            child: child,
          ),
        ),
      ),
    );

    return GestureDetector(
      onTap: onPressed,
      child: button,
    );
  }
}
