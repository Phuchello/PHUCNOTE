import 'package:flutter/material.dart';

abstract final class StudioTokens {
  static const navy = Color(0xFF18324B);
  static const blue = Color(0xFF254F7D);
  static const paper = Color(0xFFFAF7EF);
  static const workspace = Color(0xFFEDF1F5);
  static const darkWorkspace = Color(0xFF171D26);
  static const surface = Color(0xFFFFFDF8);
  static const darkSurface = Color(0xFF202A36);
  static const controlRadius = 10.0;
  static const menuRadius = 16.0;
  static const toolbarRadius = 20.0;
  static const panelRadius = 24.0;
  static const touchTarget = 48.0;
}

ThemeData academicTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final colors =
      ColorScheme.fromSeed(
        seedColor: StudioTokens.blue,
        brightness: brightness,
      ).copyWith(
        primary: dark ? const Color(0xFFAAC9EC) : StudioTokens.blue,
        onPrimary: dark ? StudioTokens.navy : Colors.white,
        primaryContainer: dark
            ? const Color(0xFF314968)
            : const Color(0xFFDFEAF6),
        onPrimaryContainer: dark ? const Color(0xFFE4EAF2) : StudioTokens.navy,
        surface: dark ? StudioTokens.darkSurface : StudioTokens.surface,
        surfaceContainerHighest: dark
            ? const Color(0xFF2B3745)
            : const Color(0xFFE7EDF3),
        onSurface: dark ? const Color(0xFFE4EAF2) : const Color(0xFF1D2D3E),
        onSurfaceVariant: dark
            ? const Color(0xFFB6C2D0)
            : const Color(0xFF5D6D7D),
        outlineVariant: dark
            ? const Color(0xFF485767)
            : const Color(0xFFCBD5DF),
        error: dark ? const Color(0xFFFFB4AB) : const Color(0xFFA63532),
      );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colors,
    fontFamily: 'Roboto',
  );
  final controlShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(StudioTokens.controlRadius),
  );
  return base.copyWith(
    scaffoldBackgroundColor: dark
        ? StudioTokens.darkWorkspace
        : StudioTokens.workspace,
    textTheme: base.textTheme.copyWith(
      titleLarge: TextStyle(
        fontSize: 20,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        color: colors.onSurface,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        height: 1.5,
        color: colors.onSurfaceVariant,
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: dark ? StudioTokens.darkSurface : StudioTokens.surface,
      foregroundColor: dark ? colors.onSurface : StudioTokens.navy,
      surfaceTintColor: Colors.transparent,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: controlShape,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: controlShape,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: controlShape,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StudioTokens.panelRadius),
      ),
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StudioTokens.menuRadius),
        side: BorderSide(color: colors.outlineVariant),
      ),
      textStyle: base.textTheme.bodyMedium?.copyWith(color: colors.onSurface),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: colors.primary,
      thumbColor: colors.primary,
      inactiveTrackColor: colors.outlineVariant,
      trackHeight: 3,
      overlayColor: colors.primary.withValues(alpha: 0.12),
      showValueIndicator: ShowValueIndicator.onDrag,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
