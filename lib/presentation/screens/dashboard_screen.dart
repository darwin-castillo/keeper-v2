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

/// Main dashboard (Manifiesto · base). Mirrors the Keeper "Dashboard (Base)"
/// design: operator session header, active manifest card, route statistics
/// and a single prominent CTA gated by the current [RouteStatus].
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
        title: const KeeperWordmark(),
        actions: [
          if (route != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(child: StatusPill.route(route.status)),
            ),
          IconButton(
            tooltip: 'Recargar ruta',
            icon: const Icon(Icons.route_rounded),
            onPressed: () => provider.loadRoute(auth.driverId ?? ''),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: provider.isLoading || route == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.loadRoute(auth.driverId ?? ''),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  const _SectionLabel('Sesión de operador'),
                  const SizedBox(height: 6),
                  Text(
                    'Bienvenido, ${auth.driverName ?? 'Operador'}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 22),
                  _ActiveManifestCard(provider: provider),
                  if (provider.status == RouteStatus.rutaIniciada ||
                      provider.status == RouteStatus.rutaPorFinalizar) ...[
                    const SizedBox(height: 16),
                    _SedeProgressCard(provider: provider),
                  ],
                  const SizedBox(height: 24),
                  const _SectionLabel('Estadísticas de ruta'),
                  const SizedBox(height: 12),
                  _TotalStopsCard(provider: provider),
                  const SizedBox(height: 12),
                  _VerifiedPackagesCard(provider: provider),
                  const SizedBox(height: 16),
                  const _InfoNote(
                    'Se requiere verificación de carga antes de iniciar la ruta.',
                  ),
                ],
              ),
            ),
      bottomNavigationBar: route == null
          ? null
          : _PrimaryAction(provider: provider),
    );
  }
}

/// Small uppercase, letter-spaced section caption.
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ActiveManifestCard extends StatelessWidget {
  final RouteProvider provider;
  const _ActiveManifestCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final route = provider.route!;
    return KeeperCard(
      accent: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _SectionLabel('Manifiesto activo')),
              const Icon(
                Icons.navigation_rounded,
                size: 18,
                color: KeeperColors.primaryBright,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ruta #${route.code.replaceAll(RegExp(r'[^0-9]'), '')}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Sector Norte · ${Formatters.date(route.assignedDate)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: KeeperColors.primary, width: 3),
              ),
            ),
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: _KeyValue(
                    label: 'Estado',
                    value: route.status.label,
                    valueColor: KeeperColors.primaryBright,
                  ),
                ),
                Expanded(
                  child: _KeyValue(
                    label: 'Sucursales',
                    value: '${route.sedes.length}',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _KeyValue({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label),
        const SizedBox(height: 4),
        Text(
          value.toUpperCase(),
          style: TextStyle(
            color: valueColor ?? Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _TotalStopsCard extends StatelessWidget {
  final RouteProvider provider;
  const _TotalStopsCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final route = provider.route!;
    return KeeperCard(
      child: Row(
        children: [
          _IconBadge(icon: Icons.place_rounded, color: KeeperColors.primary),
          const SizedBox(width: 14),
          const Expanded(child: _SectionLabel('Sucursales Totales')),
          Text(
            '${route.sedes.length}',
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ],
      ),
    );
  }
}

class _VerifiedPackagesCard extends StatelessWidget {
  final RouteProvider provider;
  const _VerifiedPackagesCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final route = provider.route!;
    final total = route.manifestPackages.length;
    final verified = route.verifiedManifestCount;
    final value = total == 0 ? 0.0 : verified / total;
    return KeeperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBadge(
                icon: Icons.qr_code_2_rounded,
                color: KeeperColors.primary,
              ),
              const SizedBox(width: 14),
              const Expanded(child: _SectionLabel('Paquetes verificados')),
              Text(
                '$verified',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Text(
                ' /$total',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation(
                KeeperColors.primaryBright,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SedeProgressCard extends StatelessWidget {
  final RouteProvider provider;
  const _SedeProgressCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final route = provider.route!;
    final currentSede = route.currentSede;
    final nextIndex = route.currentSedeIndex + 1;
    final nextSede = nextIndex < route.sedes.length
        ? route.sedes[nextIndex]
        : null;

    final bool isInProcess =
        currentSede != null && currentSede.status == SedeStatus.inProcess;

    return KeeperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Progreso de ruta'),
          const SizedBox(height: 12),
          // Current sede
          if (isInProcess)
            _SedeRow(
              icon: Icons.storefront_rounded,
              iconColor: KeeperColors.success,
              label: 'Sede actual',
              name: currentSede.name,
              subtitle: currentSede.address,
            ),
          if (isInProcess && nextSede != null) const SizedBox(height: 12),
          // Next sede
          if (nextSede != null)
            _SedeRow(
              icon: Icons.arrow_forward_rounded,
              iconColor: KeeperColors.primaryBright,
              label: 'Próxima parada',
              name: nextSede.name,
              subtitle: nextSede.address,
            ),
          if (!isInProcess && nextSede == null && currentSede != null)
            _SedeRow(
              icon: Icons.storefront_rounded,
              iconColor: KeeperColors.primaryBright,
              label: 'Siguiente parada',
              name: currentSede.name,
              subtitle: currentSede.address,
            ),
        ],
      ),
    );
  }
}

class _SedeRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String name;
  final String subtitle;
  const _SedeRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.name,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _InfoNote extends StatelessWidget {
  final String text;
  const _InfoNote(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
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
      RouteStatus.enBase => (
        'Iniciar verificación de ruta',
        Icons.qr_code_scanner_rounded,
        true,
      ),
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: ElevatedButton.icon(
          onPressed: enabled ? () => _onPressed(context) : null,
          icon: Icon(icon),
          label: Text(label.toUpperCase()),
        ),
      ),
    );
  }
}
