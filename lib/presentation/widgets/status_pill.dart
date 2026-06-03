import 'package:flutter/material.dart';

import '../../core/enums/route_enums.dart';
import '../../core/theme/keeper_colors.dart';

/// A compact, high-contrast status chip used across the app.
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
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

  /// Factory mapping a [RouteStatus] to its branded color/icon.
  factory StatusPill.route(RouteStatus status) {
    return switch (status) {
      RouteStatus.enBase => StatusPill(
          label: status.label,
          color: KeeperColors.textSecondary,
          icon: Icons.home_work_rounded,
        ),
      RouteStatus.rutaVerificada => StatusPill(
          label: status.label,
          color: KeeperColors.primaryBright,
          icon: Icons.fact_check_rounded,
        ),
      RouteStatus.rutaIniciada => StatusPill(
          label: status.label,
          color: KeeperColors.success,
          icon: Icons.local_shipping_rounded,
        ),
      RouteStatus.rutaPorFinalizar => StatusPill(
          label: status.label,
          color: KeeperColors.warning,
          icon: Icons.flag_rounded,
        ),
      RouteStatus.finalizada => StatusPill(
          label: status.label,
          color: KeeperColors.success,
          icon: Icons.task_alt_rounded,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
