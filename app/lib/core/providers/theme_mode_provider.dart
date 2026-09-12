import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider =
    StateProvider<ThemeMode>((ref) => ThemeMode.system);

Future<ThemeMode> loadSavedThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final index = prefs.getInt('theme_mode') ?? 0;
  return ThemeMode.values[index.clamp(0, ThemeMode.values.length - 1)];
}
