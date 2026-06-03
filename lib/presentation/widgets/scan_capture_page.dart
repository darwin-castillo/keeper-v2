import 'package:flutter/material.dart';

import '../../core/theme/keeper_colors.dart';
import 'scanner_view.dart';

/// Full-screen one-shot capture used for QR check-ins (base exit, sede
/// entrance, route close). Pops with the scanned string, or null if canceled.
///
/// Provides a manual-entry fallback so the flow remains testable on
/// emulators / devices without a usable camera.
class ScanCapturePage extends StatefulWidget {
  final String title;
  final String hint;

  const ScanCapturePage({
    super.key,
    required this.title,
    this.hint = 'Apunta al código QR',
  });

  /// Opens the capture page and returns the scanned value (or null).
  static Future<String?> open(
    BuildContext context, {
    required String title,
    String hint = 'Apunta al código QR',
  }) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ScanCapturePage(title: title, hint: hint),
      ),
    );
  }

  @override
  State<ScanCapturePage> createState() => _ScanCapturePageState();
}

class _ScanCapturePageState extends State<ScanCapturePage> {
  bool _handled = false;

  void _submit(String code) {
    if (_handled) return;
    _handled = true;
    Navigator.of(context).pop(code);
  }

  Future<void> _manualEntry() async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ingresar código manualmente'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(hintText: 'CÓDIGO-QR'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: ElevatedButton.styleFrom(minimumSize: const Size(88, 44)),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    if (code != null && code.trim().isNotEmpty) _submit(code.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Ingreso manual',
            icon: const Icon(Icons.keyboard_rounded),
            onPressed: _manualEntry,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: ScannerView(onCode: _submit, hint: widget.hint),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: _manualEntry,
            icon: const Icon(Icons.keyboard_rounded,
                color: KeeperColors.textPrimary),
            label: const Text('Ingresar código manualmente'),
          ),
        ),
      ),
    );
  }
}
