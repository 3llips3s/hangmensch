import 'package:flutter/material.dart';

/// Defines layout constants used for sizing, padding, and spacing across the UI.
class LayoutConstants {
  static const double maxWidth = 600.0;
  static const double horizontalPadding = 24.0;
  static const double verticalPadding = 32.0;

  static const double borderRadius = 12.0;
  static const double buttonBorderWidth = 3.0;

  /// Defines a standard spacing scale for the layout.
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;

  /// Height used for the top bar component.
  static const double topBarHeightCode = 80.0;

  static EdgeInsets screenPadding(BuildContext context) {
    return const EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: verticalPadding,
    );
  }
}
