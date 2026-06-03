import 'package:flutter/material.dart';

import '../../core/theme/keeper_colors.dart';
import '../../core/theme/keeper_theme.dart';

/// A branded surface card with optional Tech-Purple accent edge.
class KeeperCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool accent;
  final VoidCallback? onTap;

  const KeeperCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.accent = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KeeperColors.surface,
      borderRadius: BorderRadius.circular(KeeperTheme.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KeeperTheme.radiusMd),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(KeeperTheme.radiusMd),
            border: Border.all(
              color: accent
                  ? KeeperColors.primary.withValues(alpha: 0.6)
                  : KeeperColors.border,
              width: accent ? 1.5 : 1,
            ),
            gradient: accent
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      KeeperColors.primary.withValues(alpha: 0.10),
                      KeeperColors.surface,
                    ],
                  )
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
