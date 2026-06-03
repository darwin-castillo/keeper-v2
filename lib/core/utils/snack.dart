import 'package:flutter/material.dart';

import '../theme/keeper_colors.dart';

/// Lightweight, branded feedback snackbars for operator actions.
abstract final class Snack {
  static void success(BuildContext context, String message) =>
      _show(context, message, KeeperColors.success, Icons.check_circle_rounded);

  static void warning(BuildContext context, String message) =>
      _show(context, message, KeeperColors.warning, Icons.warning_amber_rounded);

  static void error(BuildContext context, String message) =>
      _show(context, message, KeeperColors.danger, Icons.error_rounded);

  static void _show(
      BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}
