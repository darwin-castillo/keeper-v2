import 'package:flutter/material.dart';

import '../../core/enums/route_enums.dart';
import '../../core/theme/keeper_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/package_model.dart';

/// Row representing a single package in verification / operation lists.
///
/// [checked] reflects the relevant scan state (base verification or on-site
/// scan). Shows a green check when done and the package amount when > 0.
class PackageTile extends StatelessWidget {
  final PackageModel package;
  final bool checked;

  const PackageTile({
    super.key,
    required this.package,
    required this.checked,
  });

  @override
  Widget build(BuildContext context) {
    final isPickup = package.type == PackageType.retiro;
    final accent = isPickup ? KeeperColors.warning : KeeperColors.success;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: checked
            ? accent.withValues(alpha: 0.10)
            : KeeperColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: checked
              ? accent.withValues(alpha: 0.55)
              : KeeperColors.border,
        ),
      ),
      child: Row(
        children: [
          _StatusDot(checked: checked, color: accent, isPickup: isPickup),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: KeeperColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  package.code,
                  style: const TextStyle(
                    color: KeeperColors.textSecondary,
                    fontSize: 12,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          if (package.amount > 0)
            Text(
              Formatters.currency(package.amount),
              style: TextStyle(
                color: checked ? accent : KeeperColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool checked;
  final Color color;
  final bool isPickup;
  const _StatusDot({
    required this.checked,
    required this.color,
    required this.isPickup,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked ? color : KeeperColors.surfaceHigh,
        border: Border.all(
          color: checked ? color : KeeperColors.border,
        ),
      ),
      child: Icon(
        checked
            ? Icons.check_rounded
            : (isPickup ? Icons.add_rounded : Icons.radio_button_unchecked),
        size: 18,
        color: checked ? Colors.white : KeeperColors.textSecondary,
      ),
    );
  }
}
