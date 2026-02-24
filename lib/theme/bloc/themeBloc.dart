import 'package:audiobook/theme/bloc/themeEvent.dart';
import 'package:audiobook/theme/bloc/themeState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/theme_services.dart';


class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeService themeService;

  ThemeBloc(this.themeService)
      : super(
    ThemeState(
      themeMode: ThemeMode.dark,
      accentColor: const Color(0xFFFF9800),
    ),
  ) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
    on<ChangeAccentColor>(_onChangeAccentColor);
  }

  Future<void> _onLoadTheme(
      LoadTheme event, Emitter<ThemeState> emit) async {
    final isDark = await themeService.getThemeMode();
    final accentValue = await themeService.getAccentColor();

    emit(
      state.copyWith(
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        accentColor: Color(accentValue),
      ),
    );
  }

  Future<void> _onToggleTheme(
      ToggleTheme event, Emitter<ThemeState> emit) async {
    final isDark = state.themeMode == ThemeMode.dark;

    await themeService.saveThemeMode(!isDark);

    emit(
      state.copyWith(
        themeMode: !isDark ? ThemeMode.dark : ThemeMode.light,
      ),
    );
  }

  Future<void> _onChangeAccentColor(
      ChangeAccentColor event, Emitter<ThemeState> emit) async {
    await themeService.saveAccentColor(event.color.value);

    emit(state.copyWith(accentColor: event.color));
  }
}