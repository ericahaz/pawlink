import 'package:flutter/material.dart';

/// Seasonal overlay without floating decorations or visual effects.
/// Seasonal theme colors and switching remain handled by
/// SeasonalController and SeasonalTheme.
class SeasonalOverlay extends StatelessWidget {
  const SeasonalOverlay({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}