import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/keeper_colors.dart';

/// Reusable live camera scanner with branded overlay and de-duplication.
///
/// Fires [onCode] for each accepted detection. Identical codes are ignored
/// within [cooldown] to prevent the camera stream from re-firing dozens of
/// times for the same barcode. Includes a torch toggle for poorly lit
/// basements/warehouses.
class ScannerView extends StatefulWidget {
  final ValueChanged<String> onCode;
  final String hint;
  final bool showTorch;

  const ScannerView({
    super.key,
    required this.onCode,
    this.hint = 'Apunta al código',
    this.showTorch = true,
  });

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  static const Duration cooldown = Duration(milliseconds: 1400);

  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  String? _lastCode;
  DateTime _lastAt = DateTime.fromMillisecondsSinceEpoch(0);
  bool _torchOn = false;

  void _handleDetect(BarcodeCapture capture) {
    if (capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    final now = DateTime.now();
    final isDuplicate = raw == _lastCode && now.difference(_lastAt) < cooldown;
    if (isDuplicate) return;

    _lastCode = raw;
    _lastAt = now;
    widget.onCode(raw);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(controller: _controller, onDetect: _handleDetect),
        // Subtle dark scrim for contrast.
        Container(color: Colors.black.withValues(alpha: 0.15)),
        // Green corner-bracket reticle (Keeper scan style).
        Center(
          child: SizedBox(
            width: 240,
            height: 200,
            child: CustomPaint(painter: _ReticlePainter()),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 24,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                widget.hint,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        if (widget.showTorch)
          Positioned(
            top: 16,
            right: 16,
            child: IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
              ),
              icon: Icon(
                _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                color: _torchOn ? KeeperColors.warning : Colors.white,
              ),
              onPressed: () {
                _controller.toggleTorch();
                setState(() => _torchOn = !_torchOn);
              },
            ),
          ),
      ],
    );
  }
}

/// Draws four green corner brackets forming the scan target.
class _ReticlePainter extends CustomPainter {
  static const double _len = 30; // bracket arm length
  static const double _r = 8; // corner radius

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = KeeperColors.success
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(0, _len)
        ..lineTo(0, _r)
        ..arcToPoint(const Offset(_r, 0), radius: const Radius.circular(_r))
        ..lineTo(_len, 0),
      paint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(w - _len, 0)
        ..lineTo(w - _r, 0)
        ..arcToPoint(Offset(w, _r), radius: const Radius.circular(_r))
        ..lineTo(w, _len),
      paint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(w, h - _len)
        ..lineTo(w, h - _r)
        ..arcToPoint(Offset(w - _r, h), radius: const Radius.circular(_r))
        ..lineTo(w - _len, h),
      paint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(_len, h)
        ..lineTo(_r, h)
        ..arcToPoint(Offset(0, h - _r), radius: const Radius.circular(_r))
        ..lineTo(0, h - _len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
