import 'package:flutter/material.dart';

import '../../core/theme/keeper_colors.dart';

/// Keeper brand mark: an image badge optionally followed by the wordmark.
class KeeperLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;

  const KeeperLogo({super.key, this.size = 48, this.showWordmark = true});

  @override
  Widget build(BuildContext context) {
    if (showWordmark) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final asset = isDark
          ? 'assets/images/logo_keeper.png'
          : 'assets/images/logo_keeper_nbg.png';
      return Container(
        padding: EdgeInsets.all(size * 0.12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Image.asset(
          asset,
          height: size,
          fit: BoxFit.contain,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: size * 0.15,
            offset: Offset(0, size * 0.06),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.12),
      child: Image.asset(
        'assets/images/logo_icon_keeper.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Compact app-bar wordmark: small icon badge + `KEEPER LOGISTICS` text.
class KeeperWordmark extends StatelessWidget {
  const KeeperWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(3),
          child: Image.asset(
            'assets/images/logo_icon_keeper.png',
            fit: BoxFit.contain,
          ),
        ),
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
        Text(
          'APP',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
