import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enums/route_enums.dart';
import '../../core/errors/keeper_exception.dart';
import '../../core/theme/keeper_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/snack.dart';
import '../../data/models/sede_model.dart';
import '../providers/route_provider.dart';
import '../widgets/keeper_logo.dart';
import '../widgets/package_tile.dart';
import '../widgets/scan_capture_page.dart';
import '../widgets/scanner_view.dart';

/// "Entrega / Retiro de Paquetes" — on-site operation at a sede.
///
/// Step 1: check-in by scanning the physical QR at the sede entrance.
/// Step 2: split layout — continuous scanner on top giving fast visual
/// feedback, scrollable list below showing delivery checks and pickup
/// amounts. Pickups prompt for the associated value before being added.
class SedeOperationScreen extends StatelessWidget {
  const SedeOperationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RouteProvider>();
    final sede = provider.currentSede;

    if (sede == null) {
      return const Scaffold(
        body: Center(child: Text('No hay una sede activa.')),
      );
    }

    return Scaffold(
      appBar: AppBar(titleSpacing: 8, title: const KeeperWordmark()),
      body: sede.status == SedeStatus.pending
          ? _CheckInGate(sede: sede)
          : _OperationView(sede: sede),
    );
  }
}

/// Mandatory check-in step: scan the QR at the sede entrance.
class _CheckInGate extends StatelessWidget {
  final SedeModel sede;
  const _CheckInGate({required this.sede});

  Future<void> _checkIn(BuildContext context) async {
    final provider = context.read<RouteProvider>();
    final code = await ScanCapturePage.open(
      context,
      title: 'Check-in de sede',
      hint: 'Escanea el QR en la entrada de la sucursal',
    );
    if (code == null || !context.mounted) return;
    try {
      await provider.checkInSedeQR(code);
      if (context.mounted) Snack.success(context, 'Check-in realizado');
    } on KeeperException catch (e) {
      if (context.mounted) Snack.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_scanner_rounded,
              size: 72,
              color: KeeperColors.primaryBright,
            ),
            const SizedBox(height: 20),
            Text(
              'Realiza el check-in',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Escanea el código QR físico en la entrada de ${sede.name} para habilitar las operaciones.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => _checkIn(context),
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Escanear QR de entrada'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Split scan + list operation view once checked-in.
class _OperationView extends StatefulWidget {
  final SedeModel sede;
  const _OperationView({required this.sede});

  @override
  State<_OperationView> createState() => _OperationViewState();
}

class _OperationViewState extends State<_OperationView> {
  /// Last confirmation message shown as a green toast over the scanner.
  String? _toast;

  void _showToast(String message) {
    setState(() => _toast = message);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  Future<void> _onScan(BuildContext context, String code) async {
    final provider = context.read<RouteProvider>();
    try {
      final result = await provider.scanPackageInSede(code);
      if (!context.mounted) return;
      switch (result) {
        case SedeScanResult.deliveredOk:
          _showToast('Paquete verificado: #$code');
          Snack.success(context, 'Entrega confirmada');
        case SedeScanResult.alreadyScanned:
          Snack.warning(context, 'Este paquete ya fue registrado');
        case SedeScanResult.pickupRequiresDetails:
          await _capturePickup(context, code);
        case SedeScanResult.invalid:
          Snack.error(context, 'Código no válido para esta sede');
      }
    } on KeeperException catch (e) {
      if (context.mounted) Snack.error(context, e.message);
    }
  }

  Future<void> _capturePickup(BuildContext context, String code) async {
    final provider = context.read<RouteProvider>();
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nuevo retiro', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Código: $code', style: Theme.of(ctx).textTheme.bodyMedium),
            const SizedBox(height: 18),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                prefixIcon: Icon(Icons.description_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Monto / valor',
                prefixText: r'$ ',
                prefixIcon: Icon(Icons.payments_rounded),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Agregar retiro'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      final amount = double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0;
      try {
        await provider.addPickupPackage(
          code: code,
          description: descCtrl.text,
          amount: amount,
        );
        if (context.mounted) Snack.success(context, 'Retiro agregado');
      } on KeeperException catch (e) {
        if (context.mounted) Snack.error(context, e.message);
      }
    }
  }

  Future<void> _complete(BuildContext context) async {
    final provider = context.read<RouteProvider>();
    try {
      await provider.completeCurrentSede();
      if (!context.mounted) return;
      Snack.success(context, 'Sede completada');
      Navigator.of(context).pop();
    } on KeeperException catch (e) {
      if (context.mounted) Snack.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RouteProvider>();
    // Re-read the live sede from the provider (the constructor copy is stale).
    final live = provider.currentSede ?? widget.sede;
    final deliveries = live.deliveryPackages;
    final pickups = live.pickupPackages;
    final canComplete = provider.canCompleteCurrentSede;
    final scanned = live.packages.where((p) => p.isScanned).length;

    return Column(
      children: [
        // --- Top: continuous scanner (fast visual feedback) -----------
        SizedBox(
          height: 240,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ScannerView(
                  onCode: (c) => _onScan(context, c),
                  hint: live.operationType.allowsPickup
                      ? 'Escanea entregas o nuevos retiros'
                      : 'Escanea el código de la entrega',
                ),
                // Green verification toast.
                Positioned(
                  top: 16,
                  left: 16,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 220),
                    offset: _toast == null
                        ? const Offset(-1.2, 0)
                        : Offset.zero,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 220),
                      opacity: _toast == null ? 0 : 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: KeeperColors.success,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF00210F),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _toast ?? '',
                              style: const TextStyle(
                                color: Color(0xFF00210F),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // --- Sede header ---------------------------------------------
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sede #${live.order} · ${live.name}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'MANIFIESTO ACTUAL · ${live.packages.length} ITEMS',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: KeeperColors.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: KeeperColors.primary.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  '$scanned/${live.packages.length}',
                  style: const TextStyle(
                    color: KeeperColors.primaryBright,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
        // --- Bottom: scrollable list ----------------------------------
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              if (deliveries.isNotEmpty) ...[
                _SectionHeader(
                  icon: Icons.inventory_2_rounded,
                  color: KeeperColors.success,
                  title: 'Entregas',
                  trailing:
                      '${deliveries.where((p) => p.isScanned).length}/${deliveries.length}',
                ),
                const SizedBox(height: 10),
                ...deliveries.map(
                  (p) => PackageTile(package: p, checked: p.isScanned),
                ),
                const SizedBox(height: 10),
              ],
              if (live.operationType.allowsPickup) ...[
                _SectionHeader(
                  icon: Icons.download_rounded,
                  color: KeeperColors.primaryDark,
                  title: 'Retiros',
                  trailing: Formatters.currency(live.pickupTotal),
                ),
                const SizedBox(height: 10),
                if (pickups.isEmpty)
                  const _EmptyHint(
                    text:
                        'Escanea los códigos de barras de los paquetes a retirar.',
                  ),
                ...pickups.map((p) => PackageTile(package: p, checked: true)),
              ],
            ],
          ),
        ),
        // --- Complete sede action (gated) -----------------------------
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: canComplete ? () => _complete(context) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: KeeperColors.lavender,
                foregroundColor: const Color(0xFF1A1033),
                disabledBackgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(
                canComplete
                    ? 'FINALIZAR OPERACIÓN'
                    : 'Completa las entregas pendientes',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String trailing;
  const _SectionHeader({
    required this.icon,
    required this.color,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        Text(
          trailing,
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
