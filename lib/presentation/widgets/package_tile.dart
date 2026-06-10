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

  const PackageTile({super.key, required this.package, required this.checked});

  @override
  Widget build(BuildContext context) {
    final isPickup = package.type == PackageType.retiro;
    final accent = isPickup ? KeeperColors.primaryDark : KeeperColors.success;
    final typeLabel = isPickup ? 'RETIRO' : 'ENTREGA';
    final meta = package.binLocation.isEmpty
        ? typeLabel
        : '$typeLabel · ${package.binLocation}';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: checked
            ? accent.withValues(alpha: 0.08)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: checked
              ? accent.withValues(alpha: 0.45)
              : Theme.of(context).colorScheme.outline,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left accent bar for verified rows.
            Container(width: 4, color: checked ? accent : Colors.transparent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${package.code}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            meta,
                            style: TextStyle(
                              color: isPickup
                                  ? KeeperColors.primaryDark
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (package.amount > 0) ...[
                      Text(
                        Formatters.currency(package.amount),
                        style: TextStyle(
                          color: checked
                              ? accent
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    _StatusDot(
                      checked: checked,
                      color: accent,
                      isPickup: isPickup,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked
            ? color
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border.all(
            color: checked ? color : Theme.of(context).colorScheme.outline),
      ),
      child: Icon(
        checked
            ? Icons.check_rounded
            : (isPickup ? Icons.add_rounded : Icons.remove_rounded),
        size: 17,
        color: checked
            ? Colors.white
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
