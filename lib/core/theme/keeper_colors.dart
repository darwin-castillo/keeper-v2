import 'package:flutter/material.dart';

/// Keeper brand palette.
///
/// Dark-mode dominant, high contrast, optimized for readability under
/// direct sunlight and for battery saving on OLED screens.
abstract final class KeeperColors {
  // --- Brand / Primary ---------------------------------------------------
  /// Tech Purple — the signature Keeper accent.
  static const Color primary = Color(0xFF5319F4);
  static const Color primaryBright = Color(0xFF8C7BFF);
  static const Color primaryDark = Color(0xFF3A0FB0);

  /// Lavender — soft purple used for confirmation buttons (FINISH OPERATION).
  static const Color lavender = Color(0xFFB9A8FF);

  // --- Neutral backgrounds (deep, slightly cool black + dark greys) ------
  /// Deep, slightly cool near-black scaffold background.
  static const Color background = Color(0xFF0B0D11);

  /// Elevated surface (cards, sheets).
  static const Color surface = Color(0xFF161922);

  /// Higher elevation surface / inputs.
  static const Color surfaceHigh = Color(0xFF1E2230);

  /// Hairline borders / dividers.
  static const Color border = Color(0xFF2A2F3D);

  // --- Text --------------------------------------------------------------
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFA0A0AD);
  static const Color textDisabled = Color(0xFF5A5A66);

  // --- State colors (combinable) -----------------------------------------
  /// Neon spring green — success / completed / checks / live status.
  static const Color success = Color(0xFF2EDF8F);
  static const Color successDark = Color(0xFF0E9C5C);

  /// Golden amber — pending / warnings / next stop / navigate.
  static const Color warning = Color(0xFFF4B740);
  static const Color warningDark = Color(0xFFC97A00);

  /// Red — errors / invalid scans.
  static const Color danger = Color(0xFFFF4D4D);

  // --- Helpers -----------------------------------------------------------
  static Color withAlpha(Color color, double opacity) =>
      color.withValues(alpha: opacity);
}
