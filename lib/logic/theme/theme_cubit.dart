
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(themeMode: ThemeMode.system));

  void toggleTheme() {
    if (state.themeMode == ThemeMode.light) {
      emit(const ThemeState(themeMode: ThemeMode.dark));
    } else {
      emit(const ThemeState(themeMode: ThemeMode.light));
    }
  }

  void setLightTheme() => emit(const ThemeState(themeMode: ThemeMode.light));

  void setDarkTheme() => emit(const ThemeState(themeMode: ThemeMode.dark));

  void setSystemTheme() => emit(const ThemeState(themeMode: ThemeMode.system));
}
