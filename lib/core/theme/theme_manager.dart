import 'package:flutter/material.dart';
import 'dark_thems.dart';
import 'light_theme.dart';

class ThemeManager {
  static ThemeData get light => lightTheme;
  static ThemeData get dark => darkTheme;
}
