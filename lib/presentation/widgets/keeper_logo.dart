import 'package:flutter/material.dart';

import '../../core/theme/keeper_colors.dart';

/// Keeper brand mark: a purple rounded badge with a shield/box glyph,
/// optionally followed by the wordmark.
class KeeperLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;

  const KeeperLogo({super.key, this.size = 48, this.showWordmark = true});

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [KeeperColors.primaryBright, KeeperColors.primary],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: KeeperColors.primary.withValues(alpha: 0.45),
            blurRadius: size * 0.4,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: Icon(
        Icons.verified_user_rounded,
        color: Colors.white,
        size: size * 0.56,
      ),
    );

    if (!showWordmark) return badge;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        badge,
        SizedBox(width: size * 0.32),
        Text(
          'Keeper',
          style: TextStyle(
            fontSize: size * 0.62,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            color: KeeperColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Compact app-bar wordmark: small badge + `KEEPER LOGISTICS` text.
class KeeperWordmark extends StatelessWidget {
  const KeeperWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const KeeperLogo(size: 28, showWordmark: false),
        const SizedBox(width: 10),
        Text(
          'KEEPER ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: KeeperColors.primaryBright,
          ),
        ),
        const Text(
          'LOGISTICS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: KeeperColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
