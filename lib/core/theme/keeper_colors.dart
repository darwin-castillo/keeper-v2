import 'package:flutter/material.dart';

/// Keeper brand palette.
abstract final class KeeperColors {
  // --- Brand / Primary ---------------------------------------------------
  /// Blue — the signature Keeper accent.
  static const Color primary = Color(0xFF2A64F4);
  static const Color primaryBright = Color(0xFF6B9AFF);
  static const Color primaryDark = Color(0xFF1A45C4);

  /// Soft blue used for confirmation buttons (FINISH OPERATION).
  static const Color lavender = Color(0xFFA8C0FF);

  // --- Light mode (default) -----------------------------------------------
  static const Color background = Color(0xFFF4F5F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceHigh = Color(0xFFEDEEF2);
  static const Color border = Color(0xFFD8DAE0);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);

  // --- Dark mode ----------------------------------------------------------
  static const Color darkBackground = Color(0xFF0B0D11);
  static const Color darkSurface = Color(0xFF161922);
  static const Color darkSurfaceHigh = Color(0xFF1E2230);
  static const Color darkBorder = Color(0xFF2A2F3D);
  static const Color darkTextPrimary = Color(0xFFF5F5F7);
  static const Color darkTextSecondary = Color(0xFFA0A0AD);
  static const Color darkTextDisabled = Color(0xFF5A5A66);

  // --- State colors (combinable) -----------------------------------------
  /// Neon spring green — success / completed / checks / live status.
  //static const Color success = Color(0xFF2EDF8F);
  //static const Color successDark = Color(0xFF0E9C5C);
  static const Color success = Color(0xFF2A64F4);
  static const Color successDark = Color(0xFF1A45C4);

  /// Golden amber — pending / warnings / next stop / navigate.
  static const Color warning = Color(0xFFF4B740);
  static const Color warningDark = Color(0xFFC97A00);

  /// Red — errors / invalid scans.
  static const Color danger = Color(0xFFFF4D4D);

  // --- Helpers -----------------------------------------------------------
  static Color withAlpha(Color color, double opacity) =>
      color.withValues(alpha: opacity);
}
