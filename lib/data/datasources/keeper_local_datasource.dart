import 'package:hive_flutter/hive_flutter.dart';

/// Thin wrapper around Hive providing the local key/value boxes used by
/// Keeper. Models are stored as plain maps (JSON-friendly), so no Hive
/// TypeAdapters / codegen are required — keeping the offline layer simple
/// and easy to migrate to SQLite/Isar later.
class KeeperLocalDataSource {
  static const String _routeBoxName = 'keeper_routes';
  static const String _activeRouteKey = 'active_route';
  static const String _seedVersionKey = 'seed_version';

  Box<dynamic>? _routeBox;

  /// Must be called once during app start-up (before runApp).
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(_routeBoxName);
  }

  Box<dynamic> get _box => _routeBox ??= Hive.box<dynamic>(_routeBoxName);

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

  /// Seed schema version persisted alongside the route. Used to invalidate a
  /// stale demo route when the seed data structure changes.
  int? readSeedVersion() => _box.get(_seedVersionKey) as int?;

  Future<void> writeSeedVersion(int version) async {
    await _box.put(_seedVersionKey, version);
  }
}
