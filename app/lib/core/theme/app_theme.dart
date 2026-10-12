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
  /// Spines and colour chips — books have nearly square corners.
  static const double xs = 2;
  static const double sm = 4;

  /// Buttons, inputs, thumbnails.
  static const double md = 6;

  /// Panels, dialogs, cards.
  static const double lg = 8;
  static const double pill = 999;
}

/// Width thresholds for the Day One–style panes.
class AppBreakpoints {
  /// Below this: one pane + bottom tab bar.
  static const double rail = 720;

  /// From this up: drawer + list + detail.
  static const double drawer = 1200;
}

/// Paper, ink and cloth colours that do not fit a [ColorScheme] slot.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  /// Entry / page surface.
  final Color paper0;

  /// Timeline column.
  final Color paper1;

  /// Drawer.
  final Color paper2;
  final Color line;
  final Color ink1;
  final Color ink2;
  final Color ink3;

  /// The one action colour (brand sunrise, darkened for contrast).
  final Color sun;
  final Color onSun;

  /// [sun] used as text: kickers, links, "Write one".
  final Color sunInk;

  /// Rules, photo borders and caps on dark cloth.
  final Color gold;

  /// Lettering stamped on a cloth cover.
  final Color foil;

  /// Text on dark cloth.
  final Color parch;
  final Color parchMute;

  const AppPalette({
    required this.paper0,
    required this.paper1,
    required this.paper2,
    required this.line,
    required this.ink1,
    required this.ink2,
    required this.ink3,
    required this.sun,
    required this.onSun,
    required this.sunInk,
    required this.gold,
    required this.foil,
    required this.parch,
    required this.parchMute,
  });

  static const light = AppPalette(
    paper0: Color(0xFFFCFAF6),
    paper1: Color(0xFFF8F3EC),
    paper2: Color(0xFFEFE9DF),
    line: Color(0xFFDED6CC),
    ink1: Color(0xFF2C1E18),
    ink2: Color(0xFF51453D),
    ink3: Color(0xFF6C6158),
    sun: Color(0xFFA64F2B),
    onSun: Color(0xFFFFFFFF),
    sunInk: Color(0xFF9A4825),
    gold: Color(0xFFD1BB92),
    foil: Color(0xFFDAC49D),
    parch: Color(0xFFF3EAD9),
    parchMute: Color(0xFFB6C2B3),
  );

  /// Redrawn, not inverted: warm brown-black paper, sun lifted toward the
  /// brand sunrise with dark lettering on it (design-demos/b-tokens.md).
  static const dark = AppPalette(
    paper0: Color(0xFF231E19),
    paper1: Color(0xFF1B1713),
    paper2: Color(0xFF15110D),
    line: Color(0xFF3C352F),
    ink1: Color(0xFFEDE5D8),
    ink2: Color(0xFFCBC1B3),
    ink3: Color(0xFFA99E91),
    sun: Color(0xFFDF8D64),
    onSun: Color(0xFF25150E),
    sunInk: Color(0xFFE8A87C),
    gold: Color(0xFFD1BB92),
    foil: Color(0xFFDAC49D),
    parch: Color(0xFFF3EAD9),
    parchMute: Color(0xFFB6C2B3),
  );

  /// Brand sunrise: open places and empty days on dark cloth (both themes).
  static const dawn = Color(0xFFE8A87C);

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>()!;

  @override
  AppPalette copyWith({
    Color? paper0,
    Color? paper1,
    Color? paper2,
    Color? line,
    Color? ink1,
    Color? ink2,
    Color? ink3,
    Color? sun,
    Color? onSun,
    Color? sunInk,
    Color? gold,
    Color? foil,
    Color? parch,
    Color? parchMute,
  }) =>
      AppPalette(
        paper0: paper0 ?? this.paper0,
        paper1: paper1 ?? this.paper1,
        paper2: paper2 ?? this.paper2,
        line: line ?? this.line,
        ink1: ink1 ?? this.ink1,
        ink2: ink2 ?? this.ink2,
        ink3: ink3 ?? this.ink3,
        sun: sun ?? this.sun,
        onSun: onSun ?? this.onSun,
        sunInk: sunInk ?? this.sunInk,
        gold: gold ?? this.gold,
        foil: foil ?? this.foil,
        parch: parch ?? this.parch,
        parchMute: parchMute ?? this.parchMute,
      );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      paper0: l(paper0, other.paper0),
      paper1: l(paper1, other.paper1),
      paper2: l(paper2, other.paper2),
      line: l(line, other.line),
      ink1: l(ink1, other.ink1),
      ink2: l(ink2, other.ink2),
      ink3: l(ink3, other.ink3),
      sun: l(sun, other.sun),
      onSun: l(onSun, other.onSun),
      sunInk: l(sunInk, other.sunInk),
      gold: l(gold, other.gold),
      foil: l(foil, other.foil),
      parch: l(parch, other.parch),
      parchMute: l(parchMute, other.parchMute),
    );
  }
}

/// Literata for anything read like a book, Be Vietnam Pro for the interface.
class AppTypography {
  static const serif = 'Literata';
  static const sans = 'Be Vietnam Pro';

  static TextTheme textTheme(AppPalette p) {
    TextStyle s(double size, FontWeight w, {double height = 1.25, double ls = 0}) =>
        TextStyle(
          fontFamily: serif,
          fontSize: size,
          fontWeight: w,
          height: height,
          letterSpacing: ls,
          color: p.ink1,
        );
    TextStyle u(double size, FontWeight w,
            {double height = 1.45, double ls = 0, Color? color}) =>
        TextStyle(
          fontFamily: sans,
          fontSize: size,
          fontWeight: w,
          height: height,
          letterSpacing: ls,
          color: color ?? p.ink1,
        );
    return TextTheme(
      displayLarge: s(52, FontWeight.w600, height: 1.05, ls: -0.5),
      displayMedium: s(40, FontWeight.w600, height: 1.1, ls: -0.3),
      displaySmall: s(32, FontWeight.w600, height: 1.12, ls: -0.2),
      headlineLarge: s(30, FontWeight.w600, height: 1.15),
      headlineMedium: s(28, FontWeight.w600, height: 1.15),
      headlineSmall: s(24, FontWeight.w600, height: 1.2),
      titleLarge: s(20, FontWeight.w600),
      titleMedium: s(18, FontWeight.w600),
      titleSmall: u(14, FontWeight.w600, height: 1.35),
      bodyLarge: u(16, FontWeight.w400, height: 1.55),
      bodyMedium: u(15, FontWeight.w400, height: 1.5),
      bodySmall: u(13, FontWeight.w400, color: p.ink3),
      labelLarge: u(14, FontWeight.w600, height: 1.2),
      labelMedium: u(12, FontWeight.w600, height: 1.2, ls: 1.2, color: p.ink3),
      labelSmall: u(12, FontWeight.w500, height: 1.2, color: p.ink3),
    );
  }

  /// Figures that line up in columns (dates, counts).
  static const figures = [FontFeature.tabularFigures(), FontFeature.liningFigures()];

  /// Body of a written memory — the one long read in the app.
  static TextStyle memory(BuildContext context) {
    final phone = MediaQuery.sizeOf(context).width < AppBreakpoints.rail;
    return TextStyle(
        fontFamily: serif,
        fontSize: phone ? 17 : 19,
        height: phone ? 1.68 : 1.74,
        fontWeight: FontWeight.w400,
        color: AppPalette.of(context).ink1,
      );
  }

  /// Trip description and other italic asides.
  static TextStyle aside(BuildContext context, {Color? color}) => TextStyle(
        fontFamily: serif,
        fontStyle: FontStyle.italic,
        fontSize: 16,
        height: 1.55,
        color: color ?? AppPalette.of(context).ink2,
      );
}

class AppTheme {
  static final ThemeData light = _build(Brightness.light, AppPalette.light);
  static final ThemeData dark = _build(Brightness.dark, AppPalette.dark);

  static ThemeData _build(Brightness brightness, AppPalette p) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.sun,
      onPrimary: p.onSun,
      secondary: p.ink2,
      onSecondary: p.paper0,
      tertiary: p.gold,
      onTertiary: p.ink1,
      error: isDark ? const Color(0xFFF2A495) : const Color(0xFFA3321F),
      onError: isDark ? const Color(0xFF1C1613) : Colors.white,
      surface: p.paper0,
      onSurface: p.ink1,
      onSurfaceVariant: p.ink3,
      surfaceContainerLowest: p.paper0,
      surfaceContainerLow: p.paper1,
      surfaceContainer: p.paper1,
      surfaceContainerHigh: p.paper2,
      surfaceContainerHighest: p.paper2,
      outline: p.ink3,
      outlineVariant: p.line,
      inverseSurface: p.ink1,
      onInverseSurface: p.paper0,
      shadow: Colors.black,
      scrim: Colors.black,
    );
    final text = AppTypography.textTheme(p);
    final buttonShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md));
    const buttonPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    final buttonSize = WidgetStateProperty.all(const Size(48, 44));
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: AppTypography.sans,
      textTheme: text,
      scaffoldBackgroundColor: p.paper0,
      canvasColor: p.paper0,
      dividerColor: p.line,
      extensions: [p],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: p.paper0,
        foregroundColor: p.ink1,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.disabled) ? p.line : p.sun),
          foregroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.disabled) ? p.ink3 : p.onSun),
          textStyle: WidgetStateProperty.all(text.labelLarge),
          padding: WidgetStateProperty.all(buttonPadding),
          minimumSize: buttonSize,
          shape: WidgetStateProperty.all(buttonShape),
          elevation: WidgetStateProperty.all(0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.ink1,
          backgroundColor: p.paper0,
          side: BorderSide(color: p.line),
          textStyle: text.labelLarge,
          padding: buttonPadding,
          minimumSize: const Size(48, 44),
          shape: buttonShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.ink2,
          textStyle: text.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          minimumSize: const Size(48, 44),
          shape: buttonShape,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          shape: buttonShape,
        ),
      ),
      iconTheme: IconThemeData(color: p.ink2, size: 20),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.paper0,
        hintStyle: text.bodyMedium?.copyWith(color: p.ink3),
        border: border(p.line),
        enabledBorder: border(p.line),
        focusedBorder: border(p.sun, 1.5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      cardTheme: CardThemeData(
        color: p.paper0,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: p.line),
        ),
      ),
      dividerTheme: DividerThemeData(color: p.line, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(
        iconColor: p.ink2,
        textColor: p.ink1,
        titleTextStyle: text.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        subtitleTextStyle: text.bodySmall,
        shape: buttonShape,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.paper1,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.sun.withValues(alpha: isDark ? 0.22 : 0.14),
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((s) =>
            text.labelSmall?.copyWith(
              color: s.contains(WidgetState.selected) ? p.ink1 : p.ink3,
              fontWeight: s.contains(WidgetState.selected)
                  ? FontWeight.w600
                  : FontWeight.w500,
            )),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
              size: 22,
              color: s.contains(WidgetState.selected) ? p.ink1 : p.ink3,
            )),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: p.ink1,
        unselectedLabelColor: p.ink3,
        labelStyle: text.labelLarge,
        unselectedLabelStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        indicatorColor: p.sun,
        dividerColor: p.line,
        indicatorSize: TabBarIndicatorSize.label,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(text.labelLarge),
          side: WidgetStateProperty.all(BorderSide(color: p.line)),
          shape: WidgetStateProperty.all(buttonShape),
          backgroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? p.paper0 : p.paper2),
          foregroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? p.ink1 : p.ink2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.paper0,
        selectedColor: p.ink1,
        labelStyle: text.labelLarge?.copyWith(color: p.ink2),
        secondaryLabelStyle: text.labelLarge?.copyWith(color: p.paper0),
        side: BorderSide(color: p.line),
        shape: const StadiumBorder(),
        showCheckmark: false,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.paper0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.paper0,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: p.line,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.paper0,
        surfaceTintColor: Colors.transparent,
        textStyle: text.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: p.line),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.ink1,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: text.labelSmall?.copyWith(color: p.paper0),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.ink1,
        contentTextStyle: text.bodyMedium?.copyWith(color: p.paper0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.sun,
        linearTrackColor: p.line,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStateProperty.all(6),
        radius: const Radius.circular(AppRadius.sm),
        thumbColor: WidgetStateProperty.all(p.ink3.withValues(alpha: 0.35)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.sun,
        foregroundColor: p.onSun,
        elevation: 1,
      ),
    );
  }
}
