import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enums/route_enums.dart';
import '../../core/theme/keeper_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/route_provider.dart';
import '../widgets/keeper_card.dart';
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
          const _MessagesTab(),
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
    (icon: Icons.chat_bubble_rounded, label: 'Mensajes', badge: true),
    (icon: Icons.account_circle_rounded, label: 'Cuenta', badge: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: KeeperColors.background,
        border: Border(top: BorderSide(color: KeeperColors.border)),
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
    final color = active ? Colors.white : KeeperColors.textSecondary;
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

class _MessagesTab extends StatelessWidget {
  const _MessagesTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline_rounded,
                size: 56, color: KeeperColors.textDisabled),
            const SizedBox(height: 14),
            Text('Sin mensajes nuevos',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Las notificaciones de la central aparecerán aquí.',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
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
          OutlinedButton.icon(
            onPressed: auth.logout,
            icon: const Icon(Icons.logout_rounded, color: KeeperColors.danger),
            label: const Text('Cerrar sesión',
                style: TextStyle(color: KeeperColors.danger)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: KeeperColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
