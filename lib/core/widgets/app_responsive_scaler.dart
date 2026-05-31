import 'package:flutter/material.dart';

/// Responsive UI Scaler widget for Mindfulness Garden.
///
/// Keeps the same base layout at 390x844 while scaling it to fit all screen sizes.
class AppResponsiveScaler extends StatelessWidget {
  final Widget child;
  final double referenceWidth;
  final double referenceHeight;

  const AppResponsiveScaler({
    super.key,
    required this.child,
    this.referenceWidth = 390,
    this.referenceHeight = 844,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scaleW = constraints.maxWidth / referenceWidth;
        final scaleH = constraints.maxHeight / referenceHeight;

        return Transform(
          transform: Matrix4.diagonal3Values(scaleW, scaleH, 1),
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: referenceWidth,
            height: referenceHeight,
            child: child,
          ),
        );
      },
    );
  }
}
