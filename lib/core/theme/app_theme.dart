import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/ui_colors.dart';

/// Defines the overall look and feel of the application through a centralized theme.
class AppTheme {
  /// Returns the configured dark theme for the application.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: UIColors.black,

      /// Configures Quicksand as the default font for the text theme.
      textTheme: GoogleFonts.quicksandTextTheme().copyWith(
        displayLarge: GoogleFonts.quicksand(
          color: UIColors.white,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.quicksand(color: UIColors.white),
      ),

      /// Adds custom text style extensions for specific numeric displays.
      extensions: [
        NumberTextStyle(
          style: GoogleFonts.jetBrainsMono(
            color: UIColors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Provides a custom theme extension for numeric typography using JetBrains Mono.
class NumberTextStyle extends ThemeExtension<NumberTextStyle> {
  /// The text style configured for numeric displays.
  final TextStyle style;

  NumberTextStyle({required this.style});

  @override
  ThemeExtension<NumberTextStyle> copyWith({TextStyle? style}) {
    return NumberTextStyle(style: style ?? this.style);
  }

  @override
  ThemeExtension<NumberTextStyle> lerp(
    ThemeExtension<NumberTextStyle>? other,
    double t,
  ) {
    if (other is! NumberTextStyle) return this;
    return NumberTextStyle(style: TextStyle.lerp(style, other.style, t)!);
  }
}

/// Provides a helper to access [NumberTextStyle] directly from [ThemeData].
extension NumberTextStyleExtension on ThemeData {
  /// Returns the custom numeric text style defined in the theme.
  TextStyle get numberStyle => extension<NumberTextStyle>()!.style;
}
