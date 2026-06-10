import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../core/enums/route_enums.dart';
import '../../core/errors/keeper_exception.dart';
import '../../data/models/package_model.dart';
import '../../data/models/route_model.dart';
import '../../data/models/sede_model.dart';
import '../../domain/repositories/route_repository.dart';

/// Result of a barcode scan performed inside a sede.
enum SedeScanResult {
  /// A pre-loaded delivery package matched and was checked.
  deliveredOk,

  /// The code matched a delivery package already scanned.
  alreadyScanned,

  /// The code is unknown but the sede allows pickups → ask for amount.
  pickupRequiresDetails,

  /// The code is invalid for this sede (e.g. delivery-only sede, no match).
  invalid,
}

/// Central state holder driving the Keeper operational state machine.
///
/// Owns the active [RouteModel], the current [RouteStatus], the active sede
/// index (strict order) and the business methods that mutate them. Every
/// mutation persists to the offline-first repository and notifies listeners.
class RouteProvider extends ChangeNotifier {
  final RouteRepository _repository;
  final _uuid = const Uuid();

  RouteProvider(this._repository);

  RouteModel? _route;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastSync;
  List<RouteModel> _completedRoutes = [];

  // --- Read-only state ---------------------------------------------------
  RouteModel? get route => _route;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastSync => _lastSync;
  List<RouteModel> get completedRoutes => _completedRoutes;

  RouteStatus get status => _route?.status ?? RouteStatus.enBase;
  List<SedeModel> get sedes => _route?.sedes ?? const [];
  SedeModel? get currentSede => _route?.currentSede;
  int get currentSedeIndex => _route?.currentSedeIndex ?? 0;

  // --- Interface gating (lock/unlock per allowed transition) -------------

  /// Manifest verification is only allowed while at base.
  bool get canVerifyPackages => status == RouteStatus.enBase;

  /// The base-exit QR can be scanned only once the manifest is verified.
  bool get canScanBaseExit => status == RouteStatus.rutaVerificada;

  /// Sede operations require the route to be in transit.
  bool get canOperateSedes => status == RouteStatus.rutaIniciada;

  /// The current sede can be checked-in if it is the next pending one.
  bool get canCheckInCurrentSede =>
      canOperateSedes && currentSede?.status == SedeStatus.pending;

  /// A sede in progress can be completed once its deliveries are done.
  bool get canCompleteCurrentSede {
    final sede = currentSede;
    if (!canOperateSedes || sede == null) return false;
    if (sede.status != SedeStatus.inProcess) return false;
    // Pure pickup sedes can be closed manually; others need deliveries done.
    return sede.operationType == SedeOperationType.retiro
        ? true
        : sede.isDeliveryComplete;
  }

  /// The closing QR can be scanned only when all sedes are processed.
  bool get canFinalize => status == RouteStatus.rutaPorFinalizar;

  // --- History -----------------------------------------------------------

  /// Loads all finalized routes for the current operator.
  Future<void> loadCompletedRoutes() async {
    final id = _route?.driverId;
    if (id == null) return;
    _completedRoutes = await _repository.getCompletedRoutes(id);
    notifyListeners();
  }

  // --- Loading -----------------------------------------------------------

  Future<void> loadRoute(String driverId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _route = await _repository.getActiveRoute(driverId);
      _lastSync = DateTime.now();
    } catch (e) {
      _error = 'No se pudo cargar la ruta: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Business methods --------------------------------------------------

  /// Verifies a manifest package by its barcode during the base load/check-out.
  /// Returns true if a package matched. Throws [KeeperException] on invalid state.
  Future<bool> verifyPackageInBase(String code) async {
    final route = _requireRoute();
    if (!canVerifyPackages) {
      throw const KeeperException(
          'La verificación en base ya no está disponible.');
    }
    final normalized = code.trim();
    var matched = false;

    final newSedes = route.sedes.map((sede) {
      final newPackages = sede.packages.map((pkg) {
        if (!matched &&
            pkg.type == PackageType.entrega &&
            pkg.code == normalized &&
            !pkg.verifiedInBase) {
          matched = true;
          return pkg.copyWith(verifiedInBase: true);
        }
        return pkg;
      }).toList();
      return sede.copyWith(packages: newPackages);
    }).toList();

    if (!matched) return false;

    var updated = route.copyWith(sedes: newSedes, pendingSync: true);
    // Auto-transition once the whole manifest is verified.
    if (updated.isManifestVerified) {
      updated = updated.copyWith(status: RouteStatus.rutaVerificada);
    }
    await _commit(updated);
    return true;
  }

  /// Scans the physical base-exit QR to start the route.
  Future<void> checkInBaseQR(String qr) async {
    final route = _requireRoute();
    if (!canScanBaseExit) {
      throw const KeeperException(
          'Primero verifica todos los paquetes en base.');
    }
    if (qr.trim() != route.baseExitQrCode) {
      throw const KeeperException('Código QR de salida no válido.');
    }
    await _commit(route.copyWith(status: RouteStatus.rutaIniciada));
  }

  /// Scans the physical QR at a sede entrance (check-in) to begin operating.
  Future<void> checkInSedeQR(String qr) async {
    final route = _requireRoute();
    final sede = route.currentSede;
    if (!canOperateSedes || sede == null) {
      throw const KeeperException('La ruta no está en tránsito.');
    }
    if (sede.status != SedeStatus.pending) {
      throw const KeeperException('Esta sede ya fue iniciada.');
    }
    if (qr.trim() != sede.checkInQrCode) {
      throw const KeeperException('El QR no corresponde a esta sede.');
    }
    final updatedSede =
        sede.copyWith(status: SedeStatus.inProcess, checkedInAt: DateTime.now());
    await _commit(_replaceSede(route, updatedSede, pendingSync: true));
  }

  /// Scans a package barcode while operating inside the current sede.
  ///
  /// For deliveries it checks the matching package. For unknown codes on a
  /// pickup-capable sede it returns [SedeScanResult.pickupRequiresDetails] so
  /// the UI can capture the amount before calling [addPickupPackage].
  Future<SedeScanResult> scanPackageInSede(String code) async {
    final route = _requireRoute();
    final sede = route.currentSede;
    if (!canOperateSedes || sede == null ||
        sede.status != SedeStatus.inProcess) {
      throw const KeeperException('Realiza el check-in de la sede primero.');
    }
    final normalized = code.trim();

    // Try delivery match first.
    final delivery = sede.deliveryPackages
        .where((p) => p.code == normalized)
        .cast<PackageModel?>()
        .firstWhere((p) => p != null, orElse: () => null);

    if (delivery != null) {
      if (delivery.isScanned) return SedeScanResult.alreadyScanned;
      final updatedPackages = sede.packages
          .map((p) => p.id == delivery.id
              ? p.copyWith(isScanned: true, scannedAt: DateTime.now())
              : p)
          .toList();
      await _commit(_replaceSede(
          route, sede.copyWith(packages: updatedPackages),
          pendingSync: true));
      return SedeScanResult.deliveredOk;
    }

    // Unknown code: only valid if the sede accepts pickups.
    if (sede.operationType.allowsPickup) {
      // Reject duplicates among already-registered pickups.
      final dup = sede.pickupPackages.any((p) => p.code == normalized);
      if (dup) return SedeScanResult.alreadyScanned;
      return SedeScanResult.pickupRequiresDetails;
    }

    return SedeScanResult.invalid;
  }

  /// Registers a newly scanned pickup package with its associated amount.
  Future<void> addPickupPackage({
    required String code,
    required String description,
    required double amount,
  }) async {
    final route = _requireRoute();
    final sede = route.currentSede;
    if (sede == null || !sede.operationType.allowsPickup) {
      throw const KeeperException('Esta sede no permite retiros.');
    }
    final pkg = PackageModel(
      id: _uuid.v4(),
      code: code.trim(),
      description: description.trim().isEmpty ? 'Retiro' : description.trim(),
      amount: amount,
      type: PackageType.retiro,
      sedeId: sede.id,
      isScanned: true,
      scannedAt: DateTime.now(),
      pendingSync: true,
    );
    final updated = sede.copyWith(packages: [...sede.packages, pkg]);
    await _commit(_replaceSede(route, updated, pendingSync: true));
  }

  /// Marks the current sede as completed and advances to the next pending one.
  Future<void> completeCurrentSede() async {
    final route = _requireRoute();
    if (!canCompleteCurrentSede) {
      throw const KeeperException(
          'Aún hay entregas pendientes en esta sede.');
    }
    final sede = route.currentSede!;
    var updated =
        _replaceSede(route, sede.copyWith(status: SedeStatus.completed));

    // Advance to the next pending sede (strict order).
    final nextIndex = updated.sedes.indexWhere(
      (s) => s.status != SedeStatus.completed,
    );
    updated = updated.copyWith(
      currentSedeIndex: nextIndex == -1 ? updated.sedes.length : nextIndex,
      pendingSync: true,
    );

    if (updated.allSedesCompleted) {
      updated = updated.copyWith(status: RouteStatus.rutaPorFinalizar);
    }
    await _commit(updated);
  }

  /// Scans the closing QR at base to finalize the route.
  Future<void> finalizeRoute(String qr) async {
    final route = _requireRoute();
    if (!canFinalize) {
      throw const KeeperException(
          'Aún hay sedes por procesar en la ruta.');
    }
    if (qr.trim() != route.baseCloseQrCode) {
      throw const KeeperException('Código QR de cierre no válido.');
    }
    final finalized = route.copyWith(status: RouteStatus.finalizada);
    await _repository.saveCompletedRoute(finalized);
    await _resetAndReload();
  }

  // --- Internal helpers --------------------------------------------------

  Future<void> _resetAndReload() async {
    final driverId = _route?.driverId;
    _route = null;
    _lastSync = null;
    notifyListeners();
    await _repository.clearRoute();
    if (driverId != null) {
      await loadRoute(driverId);
    }
  }

  RouteModel _requireRoute() {
    final route = _route;
    if (route == null) {
      throw const KeeperException('No hay una ruta activa.');
    }
    return route;
  }

  RouteModel _replaceSede(RouteModel route, SedeModel sede,
      {bool pendingSync = false}) {
    final sedes =
        route.sedes.map((s) => s.id == sede.id ? sede : s).toList();
    return route.copyWith(sedes: sedes, pendingSync: pendingSync);
  }

  Future<void> _commit(RouteModel route) async {
    _route = route;
    _lastSync = DateTime.now();
    notifyListeners();
    await _repository.saveRoute(route);
  }
}
