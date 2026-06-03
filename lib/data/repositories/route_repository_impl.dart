import '../../domain/repositories/route_repository.dart';
import '../datasources/keeper_local_datasource.dart';
import '../datasources/route_seed_data.dart';
import '../models/route_model.dart';

/// Offline-first implementation of [RouteRepository] backed by Hive.
///
/// On first access (no local route yet) it seeds a demo route so the MVP is
/// immediately usable. All mutations are persisted locally; a real sync
/// service would later push `pendingSync` entities to the backend.
class RouteRepositoryImpl implements RouteRepository {
  final KeeperLocalDataSource _local;

  RouteRepositoryImpl(this._local);

  @override
  Future<RouteModel?> getActiveRoute(String driverId) async {
    final stored = _local.readActiveRoute();
    if (stored != null) {
      return RouteModel.fromMap(stored);
    }
    // No local route: seed one for the driver and persist it.
    final seeded = RouteSeedData.buildFor(driverId);
    await saveRoute(seeded);
    return seeded;
  }

  @override
  Future<void> saveRoute(RouteModel route) async {
    await _local.writeActiveRoute(route.toMap());
  }

  @override
  Future<void> clearRoute() async {
    await _local.deleteActiveRoute();
  }
}
