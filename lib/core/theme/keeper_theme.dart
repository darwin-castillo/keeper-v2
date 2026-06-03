import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'keeper_colors.dart';

/// Central design system for the Keeper application.
///
/// Provides a dark-mode dominant [ThemeData] built around the Tech Purple
/// brand color, deep black backgrounds and high-legibility typography.
abstract final class KeeperTheme {
  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 24;

  /// System overlay style (status bar / nav bar) matching the dark theme.
  static const SystemUiOverlayStyle systemOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: KeeperColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  );

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
      surface: KeeperColors.surface,
      onSurface: KeeperColors.textPrimary,
      surfaceContainerHighest: KeeperColors.surfaceHigh,
      outline: KeeperColors.border,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: KeeperColors.background,
      splashColor: KeeperColors.primary.withValues(alpha: 0.12),
      highlightColor: KeeperColors.primary.withValues(alpha: 0.08),
      dividerColor: KeeperColors.border,
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: KeeperColors.background,
        foregroundColor: KeeperColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: systemOverlay,
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
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
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
        fillColor: KeeperColors.surfaceHigh,
        hintStyle: const TextStyle(color: KeeperColors.textDisabled),
        labelStyle: const TextStyle(color: KeeperColors.textSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: KeeperColors.primary),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    // High-legibility, slightly tightened headlines; comfortable body sizes.
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
            color: KeeperColors.textSecondary,
          ),
          labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        )
        .apply(
          bodyColor: KeeperColors.textPrimary,
          displayColor: KeeperColors.textPrimary,
        );
  }
}
