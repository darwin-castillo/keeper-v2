import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enums/route_enums.dart';
import '../../core/theme/keeper_colors.dart';
import '../../core/utils/map_launcher.dart';
import '../../core/utils/snack.dart';
import '../../data/models/sede_model.dart';
import '../providers/route_provider.dart';
import '../widgets/status_pill.dart';
import 'sede_operation_screen.dart';

/// "Estado de la Ruta" — strictly ordered, enumerated timeline of sedes.
///
/// Highlights the next mandatory sede, exposes external navigation, and lets
/// the operator open the current sede operation screen (gated by order).
class RouteStatusScreen extends StatelessWidget {
  const RouteStatusScreen({super.key});

  Future<void> _navigate(BuildContext context, SedeModel sede) async {
    final ok = await MapLauncher.navigateTo(
      latitude: sede.latitude,
      longitude: sede.longitude,
      label: sede.name,
    );
    if (!ok && context.mounted) {
      Snack.error(context, 'No se pudo abrir la app de mapas.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RouteProvider>();
    final route = provider.route!;
    final sedes = route.sedes;
    final currentIndex = route.currentSedeIndex;

    return Scaffold(
      appBar: AppBar(title: const Text('Estado de la ruta')),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: sedes.length,
        itemBuilder: (context, i) {
          final sede = sedes[i];
          final isCurrent = i == currentIndex &&
              provider.status == RouteStatus.rutaIniciada;
          final isLast = i == sedes.length - 1;
          return _TimelineNode(
            sede: sede,
            position: i + 1,
            isCurrent: isCurrent,
            isLast: isLast,
            onNavigate: () => _navigate(context, sede),
            onOpen: isCurrent
                ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SedeOperationScreen(),
                      ),
                    )
                : null,
          );
        },
      ),
    );
  }
}

/// One enumerated node in the vertical timeline.
class _TimelineNode extends StatelessWidget {
  final SedeModel sede;
  final int position;
  final bool isCurrent;
  final bool isLast;
  final VoidCallback onNavigate;
  final VoidCallback? onOpen;

  const _TimelineNode({
    required this.sede,
    required this.position,
    required this.isCurrent,
    required this.isLast,
    required this.onNavigate,
    required this.onOpen,
  });

  Color get _nodeColor => switch (sede.status) {
        SedeStatus.completed => KeeperColors.success,
        SedeStatus.inProcess => KeeperColors.primaryBright,
        SedeStatus.pending =>
          isCurrent ? KeeperColors.warning : KeeperColors.textDisabled,
      };

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Enumerated marker + connector --------------------------
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sede.status == SedeStatus.completed
                      ? KeeperColors.success
                      : KeeperColors.surface,
                  border: Border.all(color: _nodeColor, width: 2),
                ),
                alignment: Alignment.center,
                child: sede.status == SedeStatus.completed
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 20)
                    : Text('$position',
                        style: TextStyle(
                          color: _nodeColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        )),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: KeeperColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // --- Sede card ----------------------------------------------
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: KeeperColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCurrent
                        ? KeeperColors.primary
                        : KeeperColors.border,
                    width: isCurrent ? 1.5 : 1,
                  ),
                  gradient: isCurrent
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            KeeperColors.primary.withValues(alpha: 0.12),
                            KeeperColors.surface,
                          ],
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(sede.name,
                              style:
                                  Theme.of(context).textTheme.titleMedium),
                        ),
                        StatusPill.sede(sede.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place_rounded,
                            size: 14, color: KeeperColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(sede.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  Theme.of(context).textTheme.bodyMedium),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _OpTag(sede.operationType),
                        if (isCurrent) ...[
                          const SizedBox(width: 8),
                          const Text('Siguiente parada',
                              style: TextStyle(
                                color: KeeperColors.warning,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              )),
                        ],
                      ],
                    ),
                    if (isCurrent) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onNavigate,
                              icon: const Icon(Icons.navigation_rounded,
                                  size: 18),
                              label: const Text('Mapa'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: onOpen,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                              ),
                              icon: const Icon(Icons.login_rounded, size: 18),
                              label: const Text('Operar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpTag extends StatelessWidget {
  final SedeOperationType type;
  const _OpTag(this.type);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: KeeperColors.surfaceHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: KeeperColors.border),
      ),
      child: Text(type.label.toUpperCase(),
          style: const TextStyle(
            color: KeeperColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          )),
    );
  }
}
