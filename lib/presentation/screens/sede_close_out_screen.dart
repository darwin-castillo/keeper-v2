import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/errors/keeper_exception.dart';
import '../../core/theme/keeper_colors.dart';
import '../../core/utils/snack.dart';
import '../providers/route_provider.dart';

/// Pre-completion screen shown before finalizing a sede operation.
///
/// Displays the attention time elapsed since check-in and lets the
/// operator record an optional incident / observation note.
class SedeCloseOutScreen extends StatefulWidget {
  const SedeCloseOutScreen({super.key});

  @override
  State<SedeCloseOutScreen> createState() => _SedeCloseOutScreenState();
}

class _SedeCloseOutScreenState extends State<SedeCloseOutScreen> {
  final _incidentCtrl = TextEditingController();
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final sede = context.read<RouteProvider>().currentSede;
    if (sede?.checkedInAt != null) {
      _elapsed = DateTime.now().difference(sede!.checkedInAt!);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _elapsed = DateTime.now().difference(sede.checkedInAt!);
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _incidentCtrl.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Future<void> _confirm() async {
    final provider = context.read<RouteProvider>();
    try {
      await provider.completeCurrentSede(incident: _incidentCtrl.text);
      if (!mounted) return;
      Snack.success(context, 'Sede completada');
      Navigator.of(context).pop();
    } on KeeperException catch (e) {
      if (mounted) Snack.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RouteProvider>();
    final sede = provider.currentSede;
    if (sede == null) {
      return const Scaffold(
        body: Center(child: Text('No hay una sede activa.')),
      );
    }

    final completed = sede.deliveryPackages.where((p) => p.isScanned).length;
    final total = sede.deliveryPackages.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Cierre de sede')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Sede name & summary
          Text(sede.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Sede #${sede.order}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Attention time
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: KeeperColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: KeeperColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.timer_rounded,
                    size: 36, color: KeeperColors.primary),
                const SizedBox(height: 8),
                Text(
                  'Tiempo de atención',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDuration(_elapsed),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: KeeperColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Packages summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryItem(
                  label: 'Entregas',
                  value: '$completed/$total',
                  color: KeeperColors.success,
                ),
                if (sede.operationType.allowsPickup) ...[
                  Container(
                    width: 1,
                    height: 32,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  _SummaryItem(
                    label: 'Retiros',
                    value: '${sede.pickupPackages.length}',
                    color: KeeperColors.primaryDark,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Incident field
          Text('Incidencia',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Si ocurrió alguna novedad durante la visita, regístrala aquí.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _incidentCtrl,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'Describe la incidencia…',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),

          // Confirm button
          ElevatedButton.icon(
            onPressed: _confirm,
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text('CONFIRMAR FINALIZACIÓN'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            )),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
