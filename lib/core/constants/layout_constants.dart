import 'package:flutter/material.dart';

class LayoutConstants {
  static const double maxWidth = 600.0;
  static const double horizontalPadding = 24.0;
  static const double verticalPadding = 32.0;

  static const double borderRadius = 12.0;
  static const double buttonBorderWidth = 3.0;

  // Spacing scale
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;

  static const double topBarHeightCode = 80.0;

  static EdgeInsets screenPadding(BuildContext context) {
    return const EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: verticalPadding,
    );
  }
}
