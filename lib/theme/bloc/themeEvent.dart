import 'package:flutter/material.dart';

abstract class ThemeEvent {}

class LoadTheme extends ThemeEvent {}

class ToggleTheme extends ThemeEvent {}

class ChangeAccentColor extends ThemeEvent {
  final Color color;
  ChangeAccentColor(this.color);
}