import 'package:flutter/material.dart';
import 'app_color.dart';

class AppTheme {
  static ThemeData darkTheme(Color accent) {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: accent,
      colorScheme: ColorScheme.dark(
        primary: accent,
      ),
      cardColor: AppColors.cardDark,
    );
  }

  static ThemeData lightTheme(Color accent) {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: accent,
      colorScheme: ColorScheme.light(
        primary: accent,
      ),
    );
  }
}