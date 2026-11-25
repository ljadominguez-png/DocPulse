import 'package:flutter/material.dart';

class AppThemeController {
  AppThemeController._();

  static final ValueNotifier<ThemeMode> mode =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  static void toggle(bool isDark) {
    mode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}