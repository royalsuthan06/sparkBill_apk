import 'package:flutter/material.dart';
import 'platform_helper.dart';

enum ScreenSize { mobile, tablet, desktop }

class Responsive {
  Responsive._();

  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return ScreenSize.mobile;
    if (width < 1024) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  static bool isMobile(BuildContext context) => getScreenSize(context) == ScreenSize.mobile;
  static bool isTablet(BuildContext context) => getScreenSize(context) == ScreenSize.tablet;
  static bool isDesktop(BuildContext context) => getScreenSize(context) == ScreenSize.desktop;

  static bool useNavRail(BuildContext context) {
    if (PlatformHelper.isDesktop) return true;
    return MediaQuery.sizeOf(context).width >= 1024;
  }

  static double contentMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 1400) return 1400;
    return width;
  }

  static double cardElevation(BuildContext context) {
    return isDesktop(context) ? 2.0 : 0.0;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return const EdgeInsets.all(12);
      case ScreenSize.tablet:
        return const EdgeInsets.all(20);
      case ScreenSize.desktop:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    }
  }
}
