import 'package:flutter/material.dart';

/// Defines the global color palette and theme colors for the application.
class UIColors {
  /// Defines colors based on the German flag palette.
  static const Color gold = Color(0xFFFFCE00);
  static const Color red = Color(0xFFDD0000);
  static const Color black = Color(0xFF000000);

  /// Defines neutral and background colors used across the application.
  static const Color grey = Color(0xFF888888);
  static const Color darkGrey = Color(0xFF222222);
  static const Color white = Color(0xFFFFFFFF);

  /// Defines color states for timers and game status indicators.
  static const Color correct = gold;
  static const Color wrong = red;
  static const Color timerNormal = gold;
  static const Color timerWarning = Color(0xFFFF8C00);
  static const Color timerCritical = red;
}
