import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'keeper_colors.dart';

/// Central design system for the Keeper application.
abstract final class KeeperTheme {
  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 24;

  /// System overlay style for light mode.
  static const SystemUiOverlayStyle systemOverlayLight = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: KeeperColors.background,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  /// System overlay style for dark mode.
  static const SystemUiOverlayStyle systemOverlayDark = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: KeeperColors.darkBackground,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  /// Default overlay (light mode).
  static const SystemUiOverlayStyle systemOverlay = systemOverlayLight;

  // ---------------------------------------------------------------------------
  // Light theme
  // ---------------------------------------------------------------------------
  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: KeeperColors.primary,
      onPrimary: Colors.white,
      primaryContainer: KeeperColors.primaryDark,
      onPrimaryContainer: Colors.white,
      secondary: KeeperColors.success,
      onSecondary: Colors.white,
      tertiary: KeeperColors.warning,
      onTertiary: Color(0xFF2A1700),
      error: KeeperColors.danger,
      onError: Colors.white,
      surface: KeeperColors.surface,
      onSurface: KeeperColors.textPrimary,
      surfaceContainerHighest: KeeperColors.surfaceHigh,
      outline: KeeperColors.border,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: KeeperColors.background,
      splashColor: KeeperColors.primary.withValues(alpha: 0.12),
      highlightColor: KeeperColors.primary.withValues(alpha: 0.08),
      dividerColor: KeeperColors.border,
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme, forDark: false),
      appBarTheme: const AppBarTheme(
        backgroundColor: KeeperColors.background,
        foregroundColor: KeeperColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: systemOverlayLight,
        titleTextStyle: TextStyle(
          color: KeeperColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: KeeperColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: KeeperColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KeeperColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: KeeperColors.surfaceHigh,
          disabledForegroundColor: KeeperColors.textDisabled,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KeeperColors.textPrimary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: KeeperColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KeeperColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KeeperColors.surfaceHigh,
        hintStyle: const TextStyle(color: KeeperColors.textDisabled),
        labelStyle: const TextStyle(color: KeeperColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: KeeperColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: KeeperColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: KeeperColors.danger),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: KeeperColors.surfaceHigh,
        labelStyle: TextStyle(
          color: KeeperColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        side: BorderSide(color: KeeperColors.border),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: KeeperColors.surfaceHigh,
        contentTextStyle: const TextStyle(color: KeeperColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: KeeperColors.primary,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dark theme
  // ---------------------------------------------------------------------------
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: KeeperColors.primary,
      onPrimary: Colors.white,
      primaryContainer: KeeperColors.primaryDark,
      onPrimaryContainer: Colors.white,
      secondary: KeeperColors.success,
      onSecondary: Color(0xFF00210F),
      tertiary: KeeperColors.warning,
      onTertiary: Color(0xFF2A1700),
      error: KeeperColors.danger,
      onError: Colors.white,
      surface: KeeperColors.darkSurface,
      onSurface: KeeperColors.darkTextPrimary,
      surfaceContainerHighest: KeeperColors.darkSurfaceHigh,
      outline: KeeperColors.darkBorder,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: KeeperColors.darkBackground,
      splashColor: KeeperColors.primary.withValues(alpha: 0.12),
      highlightColor: KeeperColors.primary.withValues(alpha: 0.08),
      dividerColor: KeeperColors.darkBorder,
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme, forDark: true),
      appBarTheme: const AppBarTheme(
        backgroundColor: KeeperColors.darkBackground,
        foregroundColor: KeeperColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: systemOverlayDark,
        titleTextStyle: TextStyle(
          color: KeeperColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: KeeperColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: KeeperColors.darkBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KeeperColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: KeeperColors.darkSurfaceHigh,
          disabledForegroundColor: KeeperColors.darkTextDisabled,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KeeperColors.darkTextPrimary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: KeeperColors.darkBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KeeperColors.primaryBright,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KeeperColors.darkSurfaceHigh,
        hintStyle: const TextStyle(color: KeeperColors.darkTextDisabled),
        labelStyle: const TextStyle(color: KeeperColors.darkTextSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: KeeperColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: KeeperColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: KeeperColors.danger),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: KeeperColors.darkSurfaceHigh,
        labelStyle: TextStyle(
          color: KeeperColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        side: BorderSide(color: KeeperColors.darkBorder),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: KeeperColors.darkSurfaceHigh,
        contentTextStyle: const TextStyle(color: KeeperColors.darkTextPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: KeeperColors.primary,
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, {required bool forDark}) {
    final textPrimary = forDark
        ? KeeperColors.darkTextPrimary
        : KeeperColors.textPrimary;
    final textSecondary = forDark
        ? KeeperColors.darkTextSecondary
        : KeeperColors.textSecondary;

    return base
        .copyWith(
          displaySmall: base.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          headlineSmall: base.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          titleLarge: base.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
          titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          bodyLarge: base.bodyLarge?.copyWith(height: 1.4, fontSize: 16),
          bodyMedium: base.bodyMedium?.copyWith(
            height: 1.4,
            color: textSecondary,
          ),
          labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        )
        .apply(bodyColor: textPrimary, displayColor: textPrimary);
  }
}
