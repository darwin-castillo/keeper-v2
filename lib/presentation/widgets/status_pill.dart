import 'package:flutter/material.dart';

import '../../core/enums/route_enums.dart';
import '../../core/theme/keeper_colors.dart';

/// A compact, high-contrast status chip used across the app.
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  /// When true, renders a leading colored dot and monospace, letter-spaced
  /// text (technical status style, e.g. `RUTA_INICIADA`).
  final bool dot;

  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.dot = false,
  });

  /// Factory mapping a [SedeStatus] to its branded color/icon.
  factory StatusPill.sede(SedeStatus status) {
    return switch (status) {
      SedeStatus.pending => const StatusPill(
        label: 'Pendiente',
        color: KeeperColors.warning,
        icon: Icons.schedule_rounded,
      ),
      SedeStatus.inProcess => const StatusPill(
        label: 'En proceso',
        color: KeeperColors.primaryBright,
        icon: Icons.bolt_rounded,
      ),
      SedeStatus.completed => const StatusPill(
        label: 'Completada',
        color: KeeperColors.success,
        icon: Icons.check_circle_rounded,
      ),
    };
  }

  /// Factory mapping a [RouteStatus] to a technical dot-style pill
  /// (e.g. `EN_BASE`, `RUTA_INICIADA`).
  factory StatusPill.route(RouteStatus status) {
    final color = switch (status) {
      RouteStatus.enBase => KeeperColors.primary,
      RouteStatus.rutaVerificada => KeeperColors.primaryBright,
      RouteStatus.rutaIniciada => KeeperColors.primaryBright,
      RouteStatus.rutaPorFinalizar => KeeperColors.warning,
      RouteStatus.finalizada => KeeperColors.success,
    };
    return StatusPill(label: status.code, color: color, dot: true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dot ? 12 : 10, vertical: 6),
      decoration: BoxDecoration(
        color: dot ? cs.surfaceContainerHighest : color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: dot ? cs.outline : color.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: 6),
                ],
              ),
            ),
            const SizedBox(width: 7),
          ] else if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: dot ? 11 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: dot ? 0.8 : 0,
              fontFamily: dot ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }
}
