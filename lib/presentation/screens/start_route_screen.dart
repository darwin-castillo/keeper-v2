import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enums/route_enums.dart';
import '../../core/errors/keeper_exception.dart';
import '../../core/theme/keeper_colors.dart';
import '../../core/utils/snack.dart';
import '../providers/route_provider.dart';
import '../widgets/scan_capture_page.dart';
import '../widgets/scanner_view.dart';

/// "Iniciar Ruta" — base load & check-out.
///
/// Split layout: a continuous barcode scanner on top, the manifest checklist
/// below. When every package is verified the route auto-advances to
/// `rutaVerificada` and the operator must scan the physical base-exit QR.
class StartRouteScreen extends StatelessWidget {
  const StartRouteScreen({super.key});

  Future<void> _onScan(BuildContext context, String code) async {
    final provider = context.read<RouteProvider>();
    try {
      final matched = await provider.verifyPackageInBase(code);
      if (!context.mounted) return;
      if (matched) {
        Snack.success(context, 'Paquete verificado');
      } else {
        Snack.warning(context, 'Código no encontrado o ya verificado');
      }
    } on KeeperException catch (e) {
      if (context.mounted) Snack.error(context, e.message);
    }
  }

  Future<void> _scanExitQr(BuildContext context) async {
    final provider = context.read<RouteProvider>();
    final code = await ScanCapturePage.open(
      context,
      title: 'QR de salida de base',
      hint: 'Escanea el QR físico en la salida',
    );
    if (code == null || !context.mounted) return;
    try {
      await provider.checkInBaseQR(code);
      if (!context.mounted) return;
      Snack.success(context, 'Ruta iniciada. ¡Buen viaje!');
      Navigator.of(context).pop();
    } on KeeperException catch (e) {
      if (context.mounted) Snack.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RouteProvider>();
    final route = provider.route!;
    final manifest = route.manifestPackages;
    final verified = route.verifiedManifestCount;
    final ready = provider.status == RouteStatus.rutaVerificada;

    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar ruta · Carga')),
      body: Column(
        children: [
          // --- Top: live scanner (split view) ---------------------------
          SizedBox(
            height: 260,
            child: provider.canVerifyPackages
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20)),
                    child: ScannerView(
                      onCode: (c) => _onScan(context, c),
                      hint: 'Escanea el código de barras del paquete',
                    ),
                  )
                : _VerifiedBanner(),
          ),
          // --- Progress ---------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Manifiesto de carga',
                    style: Theme.of(context).textTheme.titleMedium),
                Text('$verified / ${manifest.length}',
                    style: const TextStyle(
                      color: KeeperColors.primaryBright,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
          ),
          // --- Bottom: checklist -----------------------------------------
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: manifest.length,
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
            onPressed: ready ? () => _scanExitQr(context) : null,
            icon: const Icon(Icons.exit_to_app_rounded),
            label: Text(ready
                ? 'Escanear QR de salida'
                : 'Verifica todos los paquetes'),
          ),
        ),
      ),
    );
  }
}

class _VerifiedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KeeperColors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: KeeperColors.success.withValues(alpha: 0.5)),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fact_check_rounded,
                color: KeeperColors.success, size: 44),
            SizedBox(height: 10),
            Text('Manifiesto verificado',
                style: TextStyle(
                  color: KeeperColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                )),
            SizedBox(height: 4),
            Text('Escanea el QR de salida para iniciar el tránsito',
                style: TextStyle(color: KeeperColors.textSecondary)),
          ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: verified
            ? KeeperColors.success.withValues(alpha: 0.10)
            : KeeperColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: verified
              ? KeeperColors.success.withValues(alpha: 0.55)
              : KeeperColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: verified
                  ? KeeperColors.success
                  : KeeperColors.surfaceHigh,
            ),
            child: Icon(
              verified ? Icons.check_rounded : Icons.qr_code_2_rounded,
              size: 18,
              color: verified ? Colors.white : KeeperColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: KeeperColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    )),
                const SizedBox(height: 2),
                Text(code,
                    style: const TextStyle(
                      color: KeeperColors.textSecondary,
                      fontSize: 12,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
