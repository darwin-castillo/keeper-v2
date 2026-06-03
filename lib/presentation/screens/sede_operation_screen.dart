import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enums/route_enums.dart';
import '../../core/errors/keeper_exception.dart';
import '../../core/theme/keeper_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/snack.dart';
import '../../data/models/sede_model.dart';
import '../providers/route_provider.dart';
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
      appBar: AppBar(
        title: Text(sede.name),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
            child: Row(
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
              ],
            ),
          ),
        ),
      ),
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
class _OperationView extends StatelessWidget {
  final SedeModel sede;
  const _OperationView({required this.sede});

  Future<void> _onScan(BuildContext context, String code) async {
    final provider = context.read<RouteProvider>();
    try {
      final result = await provider.scanPackageInSede(code);
      if (!context.mounted) return;
      switch (result) {
        case SedeScanResult.deliveredOk:
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
      backgroundColor: KeeperColors.surface,
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
    final live = provider.currentSede ?? sede;
    final deliveries = live.deliveryPackages;
    final pickups = live.pickupPackages;
    final canComplete = provider.canCompleteCurrentSede;

    return Column(
      children: [
        // --- Top: continuous scanner (fast visual feedback) -----------
        SizedBox(
          height: 240,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            child: ScannerView(
              onCode: (c) => _onScan(context, c),
              hint: live.operationType.allowsPickup
                  ? 'Escanea entregas o nuevos retiros'
                  : 'Escanea el código de la entrega',
            ),
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
                  icon: Icons.add_box_rounded,
                  color: KeeperColors.warning,
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
                backgroundColor: KeeperColors.success,
                disabledBackgroundColor: KeeperColors.surfaceHigh,
              ),
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(
                canComplete
                    ? 'Completar sede'
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
        color: KeeperColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KeeperColors.border),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
