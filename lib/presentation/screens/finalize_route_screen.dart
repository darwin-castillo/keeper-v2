import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enums/route_enums.dart';
import '../../core/errors/keeper_exception.dart';
import '../../core/theme/keeper_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/snack.dart';
import '../providers/route_provider.dart';
import '../widgets/keeper_card.dart';
import '../widgets/scan_capture_page.dart';
import '../widgets/status_pill.dart';

/// "Finalizar Ruta" — return to base.
///
/// Shows the summary of completed sedes and totals; the operator scans the
/// physical closing QR at base to finalize the operation.
class FinalizeRouteScreen extends StatelessWidget {
  const FinalizeRouteScreen({super.key});

  Future<void> _finalize(BuildContext context) async {
    final provider = context.read<RouteProvider>();
    final code = await ScanCapturePage.open(
      context,
      title: 'QR de cierre en base',
      hint: 'Escanea el QR de cierre al volver a base',
    );
    if (code == null || !context.mounted) return;
    try {
      await provider.finalizeRoute(code);
      if (!context.mounted) return;
      Snack.success(context, 'Ruta finalizada correctamente');
      Navigator.of(context).pop();
    } on KeeperException catch (e) {
      if (context.mounted) Snack.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RouteProvider>();
    final route = provider.route;
    if (route == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final finalized = route.status == RouteStatus.finalizada;
    final pickupTotal = route.sedes.fold<double>(
      0,
      (s, sede) => s + sede.pickupTotal,
    );
    final deliveredTotal = route.sedes.fold<double>(
      0,
      (s, sede) => s + sede.deliveredTotal,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar ruta')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          KeeperCard(
            accent: true,
            child: Row(
              children: [
                Icon(
                  finalized ? Icons.task_alt_rounded : Icons.flag_rounded,
                  color: finalized
                      ? KeeperColors.primaryDark
                      : KeeperColors.primaryBright,
                  size: 40,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        finalized ? 'Ruta cerrada' : 'Listo para volver a base',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${route.completedSedesCount}/${route.sedes.length} sedes completadas',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  label: 'Entregado',
                  value: Formatters.currency(deliveredTotal),
                  color: KeeperColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryTile(
                  label: 'Retirado',
                  value: Formatters.currency(pickupTotal),
                  color: KeeperColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Sedes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ...route.sedes.map(
            (sede) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: KeeperCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: Text(
                        '${sede.order}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        sede.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    StatusPill.sede(sede.status),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: finalized ? null : () => _finalize(context),
            icon: Icon(
              finalized ? Icons.check_rounded : Icons.qr_code_scanner_rounded,
            ),
            label: Text(
              finalized ? 'Ruta finalizada' : 'Escanear QR de cierre',
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return KeeperCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
