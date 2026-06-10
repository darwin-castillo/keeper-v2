import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/errors/keeper_exception.dart';
import '../../core/theme/keeper_colors.dart';
import '../../core/utils/snack.dart';
import '../providers/route_provider.dart';
import '../widgets/scanner_view.dart';

/// Phases of the start-route screen.
enum _Phase { verifying, scanning, ready }

/// "Iniciar Ruta" — base load & check-out.
///
/// New flow:
///   1. **Verificación automática**: the system verifies packages one by one
///      (simulated). The operator watches checks appear in real time.
///   2. **Escaneo de QR**: once all packages are verified, the camera opens
///      for the operator to scan the base-exit QR.
///   3. **Iniciar ruta**: after scanning the QR, the start button is enabled.
class StartRouteScreen extends StatefulWidget {
  const StartRouteScreen({super.key});

  @override
  State<StartRouteScreen> createState() => _StartRouteScreenState();
}

class _StartRouteScreenState extends State<StartRouteScreen> {
  _Phase _phase = _Phase.verifying;
  String? _exitQrCode;
  bool _verificationStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_verificationStarted) {
      _verificationStarted = true;
      // Delay slightly so the list is rendered before animation starts.
      Future.microtask(_runVerificationSimulation);
    }
  }

  /// Simulates system verification: verifies each unverified package with a
  /// staggered delay so the operator sees real-time progress.
  Future<void> _runVerificationSimulation() async {
    final provider = context.read<RouteProvider>();
    final route = provider.route;
    if (route == null) return;

    final unverified = route.manifestPackages
        .where((p) => !p.verifiedInBase)
        .toList();

    for (final pkg in unverified) {
      if (!mounted) return;
      // Stagger between 600ms and 1200ms to feel realistic.
      await Future.delayed(
        Duration(milliseconds: 700 + (unverified.indexOf(pkg) % 3) * 250),
      );
      if (!mounted) return;
      await provider.verifyPackageInBase(pkg.code);
    }

    if (!mounted) return;
    setState(() => _phase = _Phase.scanning);
  }

  /// Called when the base-exit QR is scanned successfully.
  void _onExitQrScanned(String code) {
    if (_phase != _Phase.scanning) return;
    final route = context.read<RouteProvider>().route;
    if (route == null) return;

    // Validate locally before enabling button.
    if (code.trim() == route.baseExitQrCode) {
      setState(() {
        _exitQrCode = code.trim();
        _phase = _Phase.ready;
      });
    } else {
      Snack.error(context, 'QR no válido. Escanea el QR de salida de base.');
    }
  }

  /// Final action: calls checkInBaseQR and pops.
  Future<void> _startRoute() async {
    final provider = context.read<RouteProvider>();
    try {
      await provider.checkInBaseQR(_exitQrCode!);
      if (!mounted) return;
      Snack.success(context, 'Ruta iniciada. ¡Buen viaje!');
      Navigator.of(context).pop();
    } on KeeperException catch (e) {
      if (mounted) Snack.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RouteProvider>();
    final route = provider.route!;
    final manifest = route.manifestPackages;
    final verified = route.verifiedManifestCount;
    final total = manifest.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar ruta')),
      body: Column(
        children: [
          // --- Top: phase-dependent area -----------------------------------
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _buildTopArea(context),
          ),
          // --- Progress header ---------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Verificación de carga',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                _ProgressPill(verified: verified, total: total),
              ],
            ),
          ),
          // --- Progress bar ------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : verified / total,
                minHeight: 6,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation(KeeperColors.success),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // --- Package checklist -------------------------------------------
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: total,
              itemBuilder: (_, i) {
                final pkg = manifest[i];
                return _ManifestTile(
                  index: i + 1,
                  description: pkg.description,
                  code: pkg.code,
                  verified: pkg.verifiedInBase,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _phase == _Phase.ready ? _startRoute : null,
            icon: Icon(
              _phase == _Phase.ready
                  ? Icons.play_arrow_rounded
                  : Icons.lock_rounded,
            ),
            label: Text(_buttonLabel.toUpperCase()),
          ),
        ),
      ),
    );
  }

  String get _buttonLabel => switch (_phase) {
    _Phase.verifying => 'Verificando carga…',
    _Phase.scanning => 'Escanea el QR de salida',
    _Phase.ready => 'Iniciar ruta',
  };

  Widget _buildTopArea(BuildContext context) {
    switch (_phase) {
      case _Phase.verifying:
        return SizedBox(
          key: const ValueKey('verifying'),
          height: 140,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: KeeperColors.primaryBright,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Verificación del sistema en curso…',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Validando cada paquete del manifiesto',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        );
      case _Phase.scanning:
        return SizedBox(
          key: const ValueKey('scanning'),
          height: 260,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            child: ScannerView(
              onCode: _onExitQrScanned,
              hint: 'Escanea el QR de salida de base',
            ),
          ),
        );
      case _Phase.ready:
        return Container(
          key: const ValueKey('ready'),
          height: 140,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: KeeperColors.success.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: KeeperColors.success.withValues(alpha: 0.5),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: KeeperColors.success,
                  size: 44,
                ),
                const SizedBox(height: 10),
                Text(
                  'Todo listo',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Presiona el botón para iniciar la ruta',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        );
    }
  }
}

/// Small pill showing "verified/total".
class _ProgressPill extends StatelessWidget {
  final int verified;
  final int total;
  const _ProgressPill({required this.verified, required this.total});

  @override
  Widget build(BuildContext context) {
    final done = verified == total;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: done
            ? KeeperColors.success.withValues(alpha: 0.14)
            : KeeperColors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: done
              ? KeeperColors.success.withValues(alpha: 0.5)
              : KeeperColors.primary.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        '$verified / $total',
        style: TextStyle(
          color: done ? KeeperColors.success : KeeperColors.primaryBright,
          fontWeight: FontWeight.w800,
          fontSize: 13,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class _ManifestTile extends StatelessWidget {
  final int index;
  final String description;
  final String code;
  final bool verified;
  const _ManifestTile({
    required this.index,
    required this.description,
    required this.code,
    required this.verified,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: verified
            ? KeeperColors.success.withValues(alpha: 0.10)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: verified
              ? KeeperColors.success.withValues(alpha: 0.55)
              : Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: verified
                  ? KeeperColors.success
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Icon(
                verified ? Icons.check_rounded : Icons.inventory_2_outlined,
                key: ValueKey(verified),
                size: 18,
                color: verified
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#$code',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: verified
                        ? KeeperColors.success
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
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
          if (verified)
            const Icon(
              Icons.verified_rounded,
              color: KeeperColors.success,
              size: 20,
            ),
        ],
      ),
    );
  }
}
