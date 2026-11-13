import 'package:flutter/material.dart';

/// Shared navigator key used by MaterialApp in main.dart.
final GlobalKey<NavigatorState> pawLinkNavigatorKey =
    GlobalKey<NavigatorState>();

/// Navigation helpers for the seasonal theme feature.
class SeasonalNavigation {
  SeasonalNavigation._();

  /// Opens the Seasonal Themes page using the /themes route in main.dart.
  static Future<void>? openShop() {
    return pawLinkNavigatorKey.currentState?.pushNamed('/themes');
  }

  /// Returns to the previous page, if one is available.
  static void goBack<T extends Object?>([T? result]) {
    final navigator = pawLinkNavigatorKey.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop<T>(result);
    }
  }
}
