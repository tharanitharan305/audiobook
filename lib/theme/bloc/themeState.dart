import 'package:flutter/material.dart';

class ThemeState {
  final ThemeMode themeMode;
  final Color accentColor;

  ThemeState({
    required this.themeMode,
    required this.accentColor,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    Color? accentColor,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}