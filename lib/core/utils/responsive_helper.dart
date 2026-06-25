import 'package:flutter/material.dart';

/// Responsive design helper for mobile and web layouts
class ResponsiveHelper {
  /// Check if screen is mobile (width < 600)
  static bool isMobile(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < 600;
  }

  /// Check if screen is tablet (width >= 600 && < 900)
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= 600 && size.width < 900;
  }

  /// Check if screen is desktop (width >= 900)
  static bool isDesktop(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= 900;
  }

  /// Get responsive font size based on screen width
  static double getResponsiveFontSize(BuildContext context, {
    required double mobileSize,
    double? tabletSize,
    double? desktopSize,
  }) {
    if (isDesktop(context)) {
      return desktopSize ?? tabletSize ?? mobileSize * 1.2;
    } else if (isTablet(context)) {
      return tabletSize ?? mobileSize * 1.1;
    }
    return mobileSize;
  }

  /// Get responsive padding based on screen width
  static double getResponsivePadding(BuildContext context, {
    required double mobilePadding,
    double? tabletPadding,
    double? desktopPadding,
  }) {
    if (isDesktop(context)) {
      return desktopPadding ?? tabletPadding ?? mobilePadding * 1.5;
    } else if (isTablet(context)) {
      return tabletPadding ?? mobilePadding * 1.2;
    }
    return mobilePadding;
  }

  /// Get responsive spacing based on screen width
  static double getResponsiveSpacing(BuildContext context, {
    required double mobileSpacing,
    double? tabletSpacing,
    double? desktopSpacing,
  }) {
    if (isDesktop(context)) {
      return desktopSpacing ?? tabletSpacing ?? mobileSpacing * 1.5;
    } else if (isTablet(context)) {
      return tabletSpacing ?? mobileSpacing * 1.2;
    }
    return mobileSpacing;
  }

  /// Get responsive container width
  static double getResponsiveContainerWidth(BuildContext context, {
    required double mobileWidth,
    double? tabletWidth,
    double? desktopWidth,
  }) {
    final size = MediaQuery.of(context).size;
    if (isDesktop(context)) {
      return desktopWidth ?? tabletWidth ?? (size.width * 0.6);
    } else if (isTablet(context)) {
      return tabletWidth ?? (size.width * 0.8);
    }
    return mobileWidth;
  }

  /// Get responsive container height
  static double getResponsiveContainerHeight(BuildContext context, {
    required double mobileHeight,
    double? tabletHeight,
    double? desktopHeight,
  }) {
    final size = MediaQuery.of(context).size;
    if (isDesktop(context)) {
      return desktopHeight ?? tabletHeight ?? (size.height * 0.7);
    } else if (isTablet(context)) {
      return tabletHeight ?? (size.height * 0.8);
    }
    return mobileHeight;
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, {
    required double mobileSize,
    double? tabletSize,
    double? desktopSize,
  }) {
    if (isDesktop(context)) {
      return desktopSize ?? tabletSize ?? mobileSize * 1.3;
    } else if (isTablet(context)) {
      return tabletSize ?? mobileSize * 1.15;
    }
    return mobileSize;
  }

  /// Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context, {
    required double mobileRadius,
    double? tabletRadius,
    double? desktopRadius,
  }) {
    if (isDesktop(context)) {
      return desktopRadius ?? tabletRadius ?? mobileRadius * 1.2;
    } else if (isTablet(context)) {
      return tabletRadius ?? mobileRadius * 1.1;
    }
    return mobileRadius;
  }

  /// Get responsive max width for content
  static double getMaxContentWidth(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (isDesktop(context)) {
      return 1200;
    } else if (isTablet(context)) {
      return 800;
    }
    return size.width;
  }

  /// Wrap content in a responsive container
  static Widget responsiveContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    double? maxWidth,
    Alignment alignment = Alignment.center,
  }) {
    final size = MediaQuery.of(context).size;
    final effectiveMaxWidth = maxWidth ?? getMaxContentWidth(context);
    
    return Container(
      width: isDesktop(context) ? effectiveMaxWidth : size.width,
      alignment: alignment,
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: getResponsivePadding(context, mobilePadding: 16),
        vertical: getResponsivePadding(context, mobilePadding: 8),
      ),
      child: child,
    );
  }

  /// Get responsive column/row count
  static int getResponsiveCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) {
      return 4;
    } else if (isTablet(context)) {
      return 3;
    }
    return 2;
  }

  /// Get responsive aspect ratio
  static double getResponsiveAspectRatio(BuildContext context) {
    if (isDesktop(context)) {
      return 16 / 9;
    } else if (isTablet(context)) {
      return 4 / 3;
    }
    return 1;
  }
}
