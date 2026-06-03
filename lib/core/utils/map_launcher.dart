import 'package:url_launcher/url_launcher.dart';

/// Opens external turn-by-turn navigation to a destination.
///
/// Uses the platform's preferred maps app (Google Maps on Android, Apple/
/// Google Maps on iOS) computing the optimal route from the driver's current
/// GPS position to the destination coordinates.
abstract final class MapLauncher {
  static Future<bool> navigateTo({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    // Universal Google Maps directions URL (falls back to web if no app).
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$latitude,$longitude'
      '&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
