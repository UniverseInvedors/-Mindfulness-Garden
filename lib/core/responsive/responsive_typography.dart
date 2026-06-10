import 'package:flutter/material.dart';

import 'responsive_context.dart';

extension ResponsiveTextStyleX on TextStyle {
  TextStyle responsive(BuildContext context) {
    final size = fontSize;
    if (size == null) return this;
    return copyWith(fontSize: context.sp(size));
  }
}

TextStyle responsiveTextStyle(
  BuildContext context,
  double size, {
  Color? color,
  FontWeight? fontWeight,
  double? height,
  double? letterSpacing,
}) {
  return TextStyle(
    fontSize: context.sp(size),
    color: color,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: letterSpacing,
  );
}
