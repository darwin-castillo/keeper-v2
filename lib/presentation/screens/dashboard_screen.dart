import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enums/route_enums.dart';
import '../../core/theme/keeper_colors.dart';
import '../../core/utils/formatters.dart';
import '../providers/auth_provider.dart';
import '../providers/route_provider.dart';
import '../widgets/keeper_card.dart';
import '../widgets/keeper_logo.dart';
import '../widgets/status_pill.dart';
import 'finalize_route_screen.dart';
import 'route_status_screen.dart';
import 'start_route_screen.dart';

/// Main dashboard. Surfaces the route summary and a single, prominent
/// primary action whose label/target changes with the [RouteStatus].
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RouteProvider>();
    final auth = context.watch<AuthProvider>();
    final route = provider.route;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const KeeperLogo(size: 32),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => auth.logout(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: provider.isLoading || route == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.loadRoute(auth.driverId ?? ''),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                children: [
                  Text(
                    'Hola, ${auth.driverName ?? 'Operador'}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Resumen de tu ruta de hoy',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  _RouteSummaryCard(provider: provider),
                  const SizedBox(height: 14),
                  _StatsRow(provider: provider),
                  const SizedBox(height: 14),
                  _NextStepHint(status: provider.status),
                ],
              ),
            ),
      bottomNavigationBar: route == null
          ? null
          : _PrimaryAction(provider: provider),
    );
  }
}

class _RouteSummaryCard extends StatelessWidget {
  final RouteProvider provider;
  const _RouteSummaryCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final route = provider.route!;
    return KeeperCard(
      accent: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ruta ${route.code}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.date(route.assignedDate),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              StatusPill.route(route.status),
            ],
          ),
          const SizedBox(height: 18),
          _ProgressBar(
            value: route.sedes.isEmpty
                ? 0
                : route.completedSedesCount / route.sedes.length,
            label:
                '${route.completedSedesCount}/${route.sedes.length} sedes completadas',
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final String label;
  const _ProgressBar({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: KeeperColors.surfaceHigh,
            valueColor: const AlwaysStoppedAnimation(
              KeeperColors.primaryBright,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final RouteProvider provider;
  const _StatsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final route = provider.route!;
    final pickupTotal = route.sedes.fold<double>(
      0,
      (s, sede) => s + sede.pickupTotal,
    );
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.inventory_2_rounded,
            color: KeeperColors.primaryBright,
            value:
                '${route.verifiedManifestCount}/${route.manifestPackages.length}',
            label: 'Paquetes verificados',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.payments_rounded,
            color: KeeperColors.success,
            value: Formatters.currency(pickupTotal),
            label: 'Total retirado',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _StatTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return KeeperCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _NextStepHint extends StatelessWidget {
  final RouteStatus status;
  const _NextStepHint({required this.status});

  @override
  Widget build(BuildContext context) {
    final (icon, text) = switch (status) {
      RouteStatus.enBase => (
        Icons.qr_code_scanner_rounded,
        'Verifica los paquetes del manifiesto escaneando su código de barras.',
      ),
      RouteStatus.rutaVerificada => (
        Icons.exit_to_app_rounded,
        'Manifiesto verificado. Escanea el QR de salida de la base para iniciar.',
      ),
      RouteStatus.rutaIniciada => (
        Icons.local_shipping_rounded,
        'En tránsito. Visita las sedes en orden y realiza el check-in con QR.',
      ),
      RouteStatus.rutaPorFinalizar => (
        Icons.flag_rounded,
        'Todas las sedes procesadas. Regresa a base y escanea el QR de cierre.',
      ),
      RouteStatus.finalizada => (
        Icons.task_alt_rounded,
        'Ruta finalizada. Buen trabajo.',
      ),
    };
    return KeeperCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(icon, color: KeeperColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: KeeperColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// The single prominent action, gated by the current route status.
class _PrimaryAction extends StatelessWidget {
  final RouteProvider provider;
  const _PrimaryAction({required this.provider});

  Future<void> _onPressed(BuildContext context) async {
    switch (provider.status) {
      case RouteStatus.enBase:
      case RouteStatus.rutaVerificada:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const StartRouteScreen()));
      case RouteStatus.rutaIniciada:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const RouteStatusScreen()));
      case RouteStatus.rutaPorFinalizar:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const FinalizeRouteScreen()));
      case RouteStatus.finalizada:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final (label, icon, enabled) = switch (provider.status) {
      RouteStatus.enBase => ('Iniciar ruta', Icons.play_arrow_rounded, true),
      RouteStatus.rutaVerificada => (
        'Continuar check-out',
        Icons.exit_to_app_rounded,
        true,
      ),
      RouteStatus.rutaIniciada => ('Ver ruta actual', Icons.map_rounded, true),
      RouteStatus.rutaPorFinalizar => (
        'Finalizar ruta',
        Icons.flag_rounded,
        true,
      ),
      RouteStatus.finalizada => (
        'Ruta finalizada',
        Icons.task_alt_rounded,
        false,
      ),
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: enabled ? () => _onPressed(context) : null,
          icon: Icon(icon),
          label: Text(label),
        ),
      ),
    );
  }
}
