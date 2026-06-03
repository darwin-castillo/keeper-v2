import 'package:hive_flutter/hive_flutter.dart';

/// Thin wrapper around Hive providing the local key/value boxes used by
/// Keeper. Models are stored as plain maps (JSON-friendly), so no Hive
/// TypeAdapters / codegen are required — keeping the offline layer simple
/// and easy to migrate to SQLite/Isar later.
class KeeperLocalDataSource {
  static const String _routeBoxName = 'keeper_routes';
  static const String _activeRouteKey = 'active_route';

  Box<dynamic>? _routeBox;

  /// Must be called once during app start-up (before runApp).
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(_routeBoxName);
  }

  Box<dynamic> get _box =>
      _routeBox ??= Hive.box<dynamic>(_routeBoxName);

  /// Returns the persisted route map, or null if none stored.
  Map<String, dynamic>? readActiveRoute() {
    final raw = _box.get(_activeRouteKey);
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw as Map);
  }

  Future<void> writeActiveRoute(Map<String, dynamic> data) async {
    await _box.put(_activeRouteKey, data);
  }

  Future<void> deleteActiveRoute() async {
    await _box.delete(_activeRouteKey);
  }
}
