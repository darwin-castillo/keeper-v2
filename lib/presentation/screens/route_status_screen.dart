import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enums/route_enums.dart';
import '../../core/theme/keeper_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/map_launcher.dart';
import '../../core/utils/snack.dart';
import '../../data/models/route_model.dart';
import '../../data/models/sede_model.dart';
import '../providers/route_provider.dart';
import '../widgets/keeper_logo.dart';
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
    final current = route.currentSede;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const KeeperWordmark(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: StatusPill.route(route.status)),
          ),
        ],
      ),
      body: Column(
        children: [
          _TimelineHeader(route: route),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: sedes.length,
              itemBuilder: (context, i) {
                final sede = sedes[i];
                final isCurrent =
                    i == currentIndex &&
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
          ),
        ],
      ),
      bottomNavigationBar: current == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: OutlinedButton.icon(
                  onPressed: () => _navigate(context, current),
                  icon: const Icon(Icons.map_rounded, size: 20),
                  label: const Text('VER EN MAPA'),
                ),
              ),
            ),
    );
  }
}

/// Header showing the route title, status and progress.
class _TimelineHeader extends StatelessWidget {
  final RouteModel route;
  const _TimelineHeader({required this.route});

  @override
  Widget build(BuildContext context) {
    final total = route.sedes.length;
    final done = route.completedSedesCount;
    final pct = total == 0 ? 0 : ((done / total) * 100).round();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ruta actual',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '$total paradas en total  ·  Progreso: $pct%',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
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

  /// Future, not-yet-active stop: rendered dimmed.
  bool get _dim => sede.status == SedeStatus.pending && !isCurrent;

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
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20,
                      )
                    : Text(
                        '$position',
                        style: TextStyle(
                          color: _nodeColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: KeeperColors.border),
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
                    _NodeStatusLine(
                      position: position,
                      sede: sede,
                      isCurrent: isCurrent,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sede.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _dim
                            ? KeeperColors.textSecondary
                            : KeeperColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.place_rounded,
                          size: 14,
                          color: KeeperColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            sede.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _OpTag(sede.operationType),
                      ],
                    ),
                    if (isCurrent) ...[
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: onNavigate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KeeperColors.warning,
                          foregroundColor: const Color(0xFF2A1700),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        icon: const Icon(Icons.navigation_rounded, size: 18),
                        label: const Text('NAVEGAR'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: onOpen,
                        icon: const Icon(Icons.login_rounded, size: 18),
                        label: const Text('Operar sede'),
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

/// Card header line: `01 · COMPLETADA` + time, or the NEXT-STOP banner.
class _NodeStatusLine extends StatelessWidget {
  final int position;
  final SedeModel sede;
  final bool isCurrent;
  const _NodeStatusLine({
    required this.position,
    required this.sede,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final pos = position.toString().padLeft(2, '0');
    final (leftText, leftColor) = switch (sede.status) {
      SedeStatus.completed => ('$pos · COMPLETADA', KeeperColors.success),
      SedeStatus.inProcess => ('$pos · EN PROCESO', KeeperColors.primaryBright),
      SedeStatus.pending =>
        isCurrent
            ? ('SIGUIENTE PARADA', KeeperColors.warning)
            : ('$pos · PENDIENTE', KeeperColors.textDisabled),
    };
    final rightText = isCurrent
        ? 'PENDIENTE'
        : (sede.checkedInAt != null ? Formatters.time(sede.checkedInAt!) : '');

    return Row(
      children: [
        Expanded(
          child: Text(
            leftText,
            style: TextStyle(
              color: leftColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ),
        if (rightText.isNotEmpty)
          Text(
            rightText,
            style: const TextStyle(
              color: KeeperColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
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
      child: Text(
        type.label.toUpperCase(),
        style: const TextStyle(
          color: KeeperColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
