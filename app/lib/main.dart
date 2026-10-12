import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/providers/theme_mode_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerFontLicenses();
  final themeMode = await loadSavedThemeMode();
  runApp(
    ProviderScope(
      overrides: [themeModeProvider.overrideWith((ref) => themeMode)],
      child: const MyApp(),
    ),
  );
}

/// Bundled OFL fonts list their licence on the app's licence page.
void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (family, file) in const [
      ('Literata', 'assets/fonts/literata_ofl.txt'),
      ('Be Vietnam Pro', 'assets/fonts/be_vietnam_pro_ofl.txt'),
    ]) {
      yield LicenseEntryWithLineBreaks([family], await rootBundle.loadString(file));
    }
  });
}
