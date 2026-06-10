import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'app_breakpoints.dart';

class ResponsiveMetrics {
  final Size size;
  final AppBreakpoint breakpoint;
  final double scale;
  final double worldScale;
  final double spacing;
  final double gutter;
  final double contentMaxWidth;
  final bool isLandscape;
  final bool isFoldable;
  final double aspectRatio;

  const ResponsiveMetrics({
    required this.size,
    required this.breakpoint,
    required this.scale,
    required this.worldScale,
    required this.spacing,
    required this.gutter,
    required this.contentMaxWidth,
    required this.isLandscape,
    required this.isFoldable,
    required this.aspectRatio,
  });

  factory ResponsiveMetrics.fromSize(Size size) {
    final safeWidth = math.max(1.0, size.width);
    final safeHeight = math.max(1.0, size.height);
    final normalized = Size(safeWidth, safeHeight);
    final shortest = math.max(320.0, normalized.shortestSide);
    final longest = normalized.longestSide;
    final aspectRatio = safeWidth / safeHeight;
    final width = size.width;
    final breakpoint = AppBreakpoints.fromWidth(width);
    final isLandscape = safeWidth >= safeHeight;
    final isFoldable = shortest >= 600 && longest / shortest < 1.45;
    final worldScale = math.min(safeWidth / 390.0, safeHeight / 844.0)
        .clamp(0.74, breakpoint.isDesktop ? 1.45 : 1.24)
        .toDouble();
    final scale = (shortest / 390)
        .clamp(0.86, breakpoint.isDesktop ? 1.32 : 1.18)
        .toDouble();
    final gutter = breakpoint.isDesktop
        ? (width * 0.04).clamp(32.0, 112.0).toDouble()
        : breakpoint.isTablet
            ? 24.0
            : breakpoint.isCompact
                ? 12.0
                : 16.0;
    return ResponsiveMetrics(
      size: normalized,
      breakpoint: breakpoint,
      scale: scale,
      worldScale: worldScale,
      spacing: 8.0 * scale,
      gutter: gutter,
      contentMaxWidth: AppBreakpoints.maxContentWidth,
      isLandscape: isLandscape,
      isFoldable: isFoldable,
      aspectRatio: aspectRatio,
    );
  }

  double dp(double value) => value * scale;

  double wu(double value) => value * worldScale;

  double sp(double value) =>
      (value * scale).clamp(value * 0.9, value * 1.35).toDouble();

  double clampWidth(double fraction, {double min = 0, double max = double.infinity}) =>
      (size.width * fraction).clamp(min, max).toDouble();

  double clampHeight(double fraction, {double min = 0, double max = double.infinity}) =>
      (size.height * fraction).clamp(min, max).toDouble();

  EdgeInsets pagePadding({double top = 1.5, double bottom = 2}) {
    return EdgeInsets.fromLTRB(gutter, spacing * top, gutter, spacing * bottom);
  }

  int columnsFor(double minTileWidth, {int min = 1, int max = 6}) {
    final usableWidth = math.min(size.width - gutter * 2, contentMaxWidth);
    return (usableWidth / minTileWidth).floor().clamp(min, max);
  }
}

class ResponsiveScope extends StatelessWidget {
  final Widget child;
  final bool safeArea;

  const ResponsiveScope({
    super.key,
    required this.child,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaSize = MediaQuery.sizeOf(context);
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : mediaSize.width;
        final height = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : mediaSize.height;
        final metrics = ResponsiveMetrics.fromSize(Size(width, height));
        final baseTextScale = MediaQuery.textScalerOf(context).scale(1.0);
        final textScale =
            (baseTextScale * metrics.scale).clamp(0.9, 1.35).toDouble();
        final scopedChild = MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: safeArea
              ? SafeArea(
                  maintainBottomViewPadding: true,
                  child: child,
                )
              : child,
        );
        return _ResponsiveInherited(
          metrics: metrics,
          child: scopedChild,
        );
      },
    );
  }
}

class _ResponsiveInherited extends InheritedWidget {
  final ResponsiveMetrics metrics;

  const _ResponsiveInherited({required this.metrics, required super.child});

  @override
  bool updateShouldNotify(_ResponsiveInherited oldWidget) =>
      metrics != oldWidget.metrics;
}

extension ResponsiveContext on BuildContext {
  ResponsiveMetrics get responsive {
    final inherited =
        dependOnInheritedWidgetOfExactType<_ResponsiveInherited>();
    return inherited?.metrics ??
        ResponsiveMetrics.fromSize(MediaQuery.sizeOf(this));
  }

  AppBreakpoint get breakpoint => responsive.breakpoint;
  bool get isMobile => breakpoint.isMobile;
  bool get isTablet => breakpoint.isTablet;
  bool get isDesktop => breakpoint.isDesktop;
  double r(double value) => responsive.dp(value);
  double wu(double value) => responsive.wu(value);
  double sp(double value) => responsive.sp(value);
  EdgeInsets get responsivePadding => responsive.pagePadding();
}

class WorldSpace extends StatelessWidget {
  final Size designSize;
  final Widget child;
  final Alignment alignment;

  const WorldSpace({
    super.key,
    this.designSize = const Size(390, 844),
    required this.child,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = context.responsive;
        final available = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : metrics.size.width,
          constraints.maxHeight.isFinite ? constraints.maxHeight : metrics.size.height,
        );
        final scale = math.min(
          available.width / designSize.width,
          available.height / designSize.height,
        );
        return Align(
          alignment: alignment,
          child: SizedBox(
            width: designSize.width * scale,
            height: designSize.height * scale,
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox.fromSize(
                size: designSize,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
