import '../../data/models/route_model.dart';

/// Contract for route persistence (Clean Architecture boundary).
///
/// The presentation layer depends on this abstraction, never on a concrete
/// storage engine. Swap the implementation (Hive/SQLite/Isar/remote) freely.
abstract interface class RouteRepository {
  /// Loads the active route for the given driver, or null if none assigned.
  Future<RouteModel?> getActiveRoute(String driverId);

  /// Persists the full route graph locally (offline-first).
  Future<void> saveRoute(RouteModel route);

  /// Clears the locally stored route (e.g. after a confirmed sync/close).
  Future<void> clearRoute();
}
