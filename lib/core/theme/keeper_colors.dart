import 'package:flutter/material.dart';

/// Keeper brand palette.
///
/// Dark-mode dominant, high contrast, optimized for readability under
/// direct sunlight and for battery saving on OLED screens.
abstract final class KeeperColors {
  // --- Brand / Primary ---------------------------------------------------
  /// Tech Purple — the signature Keeper accent.
  static const Color primary = Color(0xFF5319F4);
  static const Color primaryBright = Color(0xFF7B4DFF);
  static const Color primaryDark = Color(0xFF3A0FB0);

  // --- Neutral backgrounds (deep black + dark neutral greys) -------------
  /// Deep black scaffold background.
  static const Color background = Color(0xFF0A0A0C);

  /// Elevated surface (cards, sheets).
  static const Color surface = Color(0xFF15151A);

  /// Higher elevation surface / inputs.
  static const Color surfaceHigh = Color(0xFF1F1F27);

  /// Hairline borders / dividers.
  static const Color border = Color(0xFF2A2A33);

  // --- Text --------------------------------------------------------------
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFA0A0AD);
  static const Color textDisabled = Color(0xFF5A5A66);

  // --- State colors (combinable) -----------------------------------------
  /// Bright emerald green — success / completed / checks.
  static const Color success = Color(0xFF13D67E);
  static const Color successDark = Color(0xFF0E9C5C);

  /// Amber / orange — pending / warnings / in-process.
  static const Color warning = Color(0xFFFFA31A);
  static const Color warningDark = Color(0xFFC97A00);

  /// Red — errors / invalid scans.
  static const Color danger = Color(0xFFFF4D4D);

  // --- Helpers -----------------------------------------------------------
  static Color withAlpha(Color color, double opacity) =>
      color.withValues(alpha: opacity);
}
