import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/ui_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: UIColors.black,
      
      // Default font is Quicksand
      textTheme: GoogleFonts.quicksandTextTheme().copyWith(
        displayLarge: GoogleFonts.quicksand(
          color: UIColors.white,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.quicksand(
          color: UIColors.white,
        ),
      ),
      
      // Mono font for numbers where specified
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

/// Custom theme extension to easily access JetBrains Mono for numbers
class NumberTextStyle extends ThemeExtension<NumberTextStyle> {
  final TextStyle style;

  NumberTextStyle({required this.style});

  @override
  ThemeExtension<NumberTextStyle> copyWith({TextStyle? style}) {
    return NumberTextStyle(style: style ?? this.style);
  }

  @override
  ThemeExtension<NumberTextStyle> lerp(ThemeExtension<NumberTextStyle>? other, double t) {
    if (other is! NumberTextStyle) return this;
    return NumberTextStyle(
      style: TextStyle.lerp(style, other.style, t)!,
    );
  }
}

extension NumberTextStyleExtension on ThemeData {
  TextStyle get numberStyle => extension<NumberTextStyle>()!.style;
}
