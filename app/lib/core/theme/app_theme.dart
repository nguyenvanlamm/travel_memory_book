import 'package:flutter/material.dart';

/// Design tokens (spacing + radius) shared across the UI.
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;
}

class AppTheme {
  // Warm palette (kept from the journal identity)
  static const Color deepBrown = Color(0xFF3E2723);
  static const Color earth = Color(0xFF5D4037);
  static const Color sunrise = Color(0xFFE8A87C);
  static const Color dusk = Color(0xFFC38D9E);
  static const Color parchment = Color(0xFFF4E4C1);
  static const Color warmWhite = Color(0xFFFAF7F2);
  static const Color trueBlack = Color(0xFF0A0A0A);

  // Dark-premium palette — slate surfaces + gold accent
  static const Color gold = Color(0xFFD4AF37);
  static const Color slate950 = Color(0xFF0B1220);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate200 = Color(0xFFE2E8F0);

  // Bundled font families (assets/fonts)
  static const String fontBody = 'Inter';
  static const String fontDisplay = 'Syne';

  // Light theme — keeps the warm parchment identity
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: fontBody,
    colorScheme: const ColorScheme.light(
      primary: deepBrown,
      secondary: earth,
      tertiary: sunrise,
      surface: warmWhite,
      surfaceContainerHighest: parchment,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: deepBrown,
      onSurfaceVariant: earth,
      outlineVariant: Color(0xFFE7DCC8),
    ),
    // Transparent so the site's WebBackdrop (gradient + grain + glows)
    // painted in the router shell shows through every nested Scaffold.
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: _textTheme(const Color(0xFF2B211B)),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: _textTheme(const Color(0xFF2B211B)).headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: deepBrown,
          ),
      iconTheme: const IconThemeData(color: deepBrown),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: Color(0xFFE7DCC8)),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: deepBrown,
      unselectedItemColor: Colors.grey.shade500,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: deepBrown,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFBF6EA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: Color(0xFFE7DCC8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: Color(0xFFE7DCC8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: deepBrown, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: deepBrown,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    dividerTheme:
        const DividerThemeData(color: Color(0xFFE7DCC8), thickness: 1),
    listTileTheme: const ListTileThemeData(
      iconColor: earth,
      textColor: deepBrown,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbVisibility: WidgetStateProperty.all(true),
      thickness: WidgetStateProperty.all(8),
      radius: const Radius.circular(8),
      thumbColor: WidgetStateProperty.all(earth.withOpacity(0.35)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
  );

  // Dark theme — dark-premium: deep slate surfaces, gold accent
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: fontBody,
    colorScheme: const ColorScheme.dark(
      primary: gold,
      secondary: slate400,
      tertiary: dusk,
      surface: slate950,
      surfaceContainerHighest: slate800,
      onPrimary: Color(0xFF1A1405),
      onSecondary: slate950,
      onSurface: slate200,
      onSurfaceVariant: slate400,
      outlineVariant: slate700,
    ),
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: _textTheme(slate200),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: _textTheme(slate200).headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: slate200,
          ),
      iconTheme: const IconThemeData(color: slate200),
    ),
    cardTheme: CardTheme(
      color: slate900,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: slate700, width: 0.8),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: slate900,
      selectedItemColor: gold,
      unselectedItemColor: slate400,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: gold,
      foregroundColor: Color(0xFF1A1405),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: slate900,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: slate700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: slate700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: gold, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: const Color(0xFF1A1405),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    dividerTheme: const DividerThemeData(color: slate700, thickness: 1),
    listTileTheme: const ListTileThemeData(
      iconColor: slate400,
      textColor: slate200,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbVisibility: WidgetStateProperty.all(true),
      thickness: WidgetStateProperty.all(8),
      radius: const Radius.circular(8),
      thumbColor: WidgetStateProperty.all(slate400.withOpacity(0.35)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
  );

  static TextTheme _textTheme(Color baseColor) {
    TextStyle syne(double size, FontWeight w, {double? ls}) => TextStyle(
          fontFamily: fontDisplay,
          fontSize: size,
          fontWeight: w,
          letterSpacing: ls,
          color: baseColor,
        );
    TextStyle inter(double size, FontWeight w, {double ls = 0}) => TextStyle(
          fontFamily: fontBody,
          fontSize: size,
          fontWeight: w,
          letterSpacing: ls,
          color: baseColor,
        );
    return TextTheme(
      displayLarge: syne(57, FontWeight.w700, ls: -0.5),
      displayMedium: syne(45, FontWeight.w700),
      displaySmall: syne(36, FontWeight.w600),
      headlineLarge: syne(32, FontWeight.w700),
      headlineMedium: syne(28, FontWeight.w700),
      headlineSmall: syne(24, FontWeight.w700),
      titleLarge: syne(22, FontWeight.w600),
      titleMedium: inter(16, FontWeight.w500, ls: 0.15),
      titleSmall: inter(14, FontWeight.w500, ls: 0.1),
      bodyLarge: inter(16, FontWeight.w400, ls: 0.3),
      bodyMedium: inter(14, FontWeight.w400, ls: 0.25),
      bodySmall: inter(12, FontWeight.w400, ls: 0.3),
      labelLarge: inter(14, FontWeight.w600, ls: 0.1),
    );
  }
}
