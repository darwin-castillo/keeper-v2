import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enums/route_enums.dart';
import '../../core/theme/keeper_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/route_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/keeper_card.dart';
import '../../core/utils/app_info.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/route_model.dart';
import 'dashboard_screen.dart';
import 'finalize_route_screen.dart';
import 'route_status_screen.dart';
import 'sede_operation_screen.dart';
import 'start_route_screen.dart';

/// Root authenticated shell with the bottom navigation bar
/// (Manifiesto · Escáner · Mensajes · Cuenta), matching the Keeper design.
///
/// The Manifiesto tab is context-aware: it shows the dashboard while at base
/// and the route timeline once the route is in transit.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final status = context.watch<RouteProvider>().status;
    final manifestTab = status == RouteStatus.rutaIniciada
        ? const RouteStatusScreen()
        : const DashboardScreen();

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          manifestTab,
          const _ScannerTab(),
          const _HistoryTab(),
          const _AccountTab(),
        ],
      ),
      bottomNavigationBar: _KeeperNavBar(
        index: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

/// Custom bottom navigation bar with a purple "pill" highlight on the
/// active destination.
class _KeeperNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _KeeperNavBar({required this.index, required this.onTap});

  static const _items = <({IconData icon, String label, bool badge})>[
    (icon: Icons.local_shipping_rounded, label: 'Manifiesto', badge: false),
    (icon: Icons.qr_code_scanner_rounded, label: 'Escáner', badge: false),
    (icon: Icons.history_rounded, label: 'Historial', badge: false),
    (icon: Icons.account_circle_rounded, label: 'Cuenta', badge: false),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: cs.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < _items.length; i++)
                _NavItem(
                  data: _items[i],
                  active: i == index,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final ({IconData icon, String label, bool badge}) data;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({
    required this.data,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active
        ? Colors.white
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? KeeperColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(data.icon, size: 22, color: color),
                if (data.badge)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: KeeperColors.danger,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              data.label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Context-aware scanner entry point.
class _ScannerTab extends StatelessWidget {
  const _ScannerTab();

  ({String title, String subtitle, String action, VoidCallback? onTap})
      _resolve(BuildContext context, RouteProvider p) {
    void push(Widget screen) => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => screen),
        );

    switch (p.status) {
      case RouteStatus.enBase:
      case RouteStatus.rutaVerificada:
        return (
          title: 'Verificación de carga',
          subtitle: 'Escanea los paquetes del manifiesto en base.',
          action: 'Abrir verificación',
          onTap: () => push(const StartRouteScreen()),
        );
      case RouteStatus.rutaIniciada:
        final sede = p.currentSede;
        return (
          title: sede?.name ?? 'Operación en sede',
          subtitle: sede?.status == SedeStatus.pending
              ? 'Realiza el check-in con QR para operar.'
              : 'Escanea entregas y retiros de la sede.',
          action: 'Operar sede',
          onTap: () => push(const SedeOperationScreen()),
        );
      case RouteStatus.rutaPorFinalizar:
        return (
          title: 'Cierre en base',
          subtitle: 'Escanea el QR de cierre al volver a base.',
          action: 'Abrir cierre',
          onTap: () => push(const FinalizeRouteScreen()),
        );
      case RouteStatus.finalizada:
        return (
          title: 'Ruta finalizada',
          subtitle: 'No hay operaciones de escaneo pendientes.',
          action: 'Sin acciones',
          onTap: null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RouteProvider>();
    final r = _resolve(context, provider);

    return Scaffold(
      appBar: AppBar(title: const Text('Escáner')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: KeeperCard(
            accent: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.qr_code_scanner_rounded,
                    size: 64, color: KeeperColors.primaryBright),
                const SizedBox(height: 18),
                Text(r.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(r.subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 22),
                ElevatedButton.icon(
                  onPressed: r.onTap,
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: Text(r.action),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryTab extends StatefulWidget {
  const _HistoryTab();

  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RouteProvider>().loadCompletedRoutes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final routes = context.watch<RouteProvider>().completedRoutes;

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: routes.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_rounded,
                      size: 56, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
                  const SizedBox(height: 14),
                  Text('Sin rutas finalizadas',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Las rutas completadas aparecerán aquí.',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: routes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _HistoryRouteCard(route: routes[i]),
            ),
    );
  }
}

class _HistoryRouteCard extends StatelessWidget {
  final RouteModel route;
  const _HistoryRouteCard({required this.route});

  @override
  Widget build(BuildContext context) {
    final total = route.sedes.length;
    final done = route.completedSedesCount;

    return KeeperCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: KeeperColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: KeeperColors.primaryBright, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.code,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${Formatters.date(route.assignedDate)} · $total paradas',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: KeeperColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$done/$total',
              style: const TextStyle(
                color: KeeperColors.success,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTab extends StatelessWidget {
  const _AccountTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Cuenta')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          KeeperCard(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: KeeperColors.primary,
                  child: Icon(Icons.person_rounded,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(auth.driverName ?? 'Operador',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text('ID: ${auth.driverId ?? '—'}',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          KeeperCard(
            child: Row(
              children: [
                Icon(Icons.dark_mode_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Modo oscuro',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('Cambia la apariencia de la app',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                    ],
                  ),
                ),
                Switch(
                  value: context.watch<ThemeProvider>().isDarkMode,
                  onChanged: (v) =>
                      context.read<ThemeProvider>().setDarkMode(v),
                  activeThumbColor: KeeperColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: auth.logout,
            icon: const Icon(Icons.logout_rounded, color: KeeperColors.danger),
            label: const Text('Cerrar sesión',
                style: TextStyle(color: KeeperColors.danger)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: KeeperColors.danger),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Versión ${AppInfo.displayVersion}',
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.38),
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
