import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/providers/theme_mode_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeMode = await loadSavedThemeMode();
  runApp(
    ProviderScope(
      overrides: [themeModeProvider.overrideWith((ref) => themeMode)],
      child: const MyApp(),
    ),
  );
}
