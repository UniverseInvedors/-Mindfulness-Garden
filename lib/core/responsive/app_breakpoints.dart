import 'package:flutter/widgets.dart';

enum AppBreakpoint { compact, mobile, tablet, desktop, tv, ultrawide }

class AppBreakpoints {
  static const double compactMax = 360;
  static const double mobileMax = 600;
  static const double tabletMax = 1024;
  static const double desktopMax = 1440;
  static const double tvMax = 2560;
  static const double maxContentWidth = 1920;

  const AppBreakpoints._();

  static AppBreakpoint fromWidth(double width) {
    if (width < compactMax) return AppBreakpoint.compact;
    if (width < mobileMax) return AppBreakpoint.mobile;
    if (width <= tabletMax) return AppBreakpoint.tablet;
    if (width <= desktopMax) return AppBreakpoint.desktop;
    if (width <= tvMax) return AppBreakpoint.tv;
    return AppBreakpoint.ultrawide;
  }
}

extension AppBreakpointX on AppBreakpoint {
  bool get isCompact => this == AppBreakpoint.compact;
  bool get isMobile => this == AppBreakpoint.compact || this == AppBreakpoint.mobile;
  bool get isTablet => this == AppBreakpoint.tablet;
  bool get isDesktop =>
      this == AppBreakpoint.desktop ||
      this == AppBreakpoint.tv ||
      this == AppBreakpoint.ultrawide;
  bool get isTv => this == AppBreakpoint.tv;
  bool get isUltrawide => this == AppBreakpoint.ultrawide;
}

extension ResponsiveSizeX on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
}
