import '../../core/enums/route_enums.dart';
import 'package_model.dart';
import 'sede_model.dart';

/// The full route assigned to a driver for the working day.
///
/// Root aggregate persisted locally (offline-first). The whole graph
/// (route -> sedes -> packages) serializes to a single JSON-friendly map.
class RouteModel {
  final String id;
  final String code;
  final String driverId;
  final DateTime assignedDate;

  /// Current operational status (drives the whole UI state machine).
  final RouteStatus status;

  /// Index (0-based) of the active sede in [sedes], respecting strict order.
  final int currentSedeIndex;

  /// Expected QR value the driver must scan at the base exit to start.
  final String baseExitQrCode;

  /// Expected QR value the driver must scan at base to close the route.
  final String baseCloseQrCode;

  /// Sedes to visit, ordered by [SedeModel.order].
  final List<SedeModel> sedes;

  /// True if the route has local changes pending sync to the backend.
  final bool pendingSync;

  const RouteModel({
    required this.id,
    required this.code,
    required this.driverId,
    required this.assignedDate,
    required this.baseExitQrCode,
    required this.baseCloseQrCode,
    required this.sedes,
    this.status = RouteStatus.enBase,
    this.currentSedeIndex = 0,
    this.pendingSync = false,
  });

  // --- Derived helpers ---------------------------------------------------

  /// All delivery packages across every sede = the base manifest to verify.
  List<PackageModel> get manifestPackages => [
        for (final sede in sedes) ...sede.deliveryPackages,
      ];

  int get verifiedManifestCount =>
      manifestPackages.where((p) => p.verifiedInBase).length;

  /// True when every manifest (delivery) package was verified at base.
  bool get isManifestVerified =>
      manifestPackages.isNotEmpty &&
      manifestPackages.every((p) => p.verifiedInBase);

  /// The next sede the driver must visit (null if all done).
  SedeModel? get currentSede =>
      (currentSedeIndex >= 0 && currentSedeIndex < sedes.length)
          ? sedes[currentSedeIndex]
          : null;

  int get completedSedesCount =>
      sedes.where((s) => s.status == SedeStatus.completed).length;

  bool get allSedesCompleted =>
      sedes.isNotEmpty && sedes.every((s) => s.status == SedeStatus.completed);

  RouteModel copyWith({
    RouteStatus? status,
    int? currentSedeIndex,
    List<SedeModel>? sedes,
    bool? pendingSync,
  }) {
    return RouteModel(
      id: id,
      code: code,
      driverId: driverId,
      assignedDate: assignedDate,
      baseExitQrCode: baseExitQrCode,
      baseCloseQrCode: baseCloseQrCode,
      status: status ?? this.status,
      currentSedeIndex: currentSedeIndex ?? this.currentSedeIndex,
      sedes: sedes ?? this.sedes,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'code': code,
        'driverId': driverId,
        'assignedDate': assignedDate.toIso8601String(),
        'status': status.key,
        'currentSedeIndex': currentSedeIndex,
        'baseExitQrCode': baseExitQrCode,
        'baseCloseQrCode': baseCloseQrCode,
        'pendingSync': pendingSync,
        'sedes': sedes.map((s) => s.toMap()).toList(),
      };

  factory RouteModel.fromMap(Map<String, dynamic> map) => RouteModel(
        id: map['id'] as String,
        code: (map['code'] as String?) ?? '',
        driverId: (map['driverId'] as String?) ?? '',
        assignedDate: DateTime.tryParse(map['assignedDate'] as String? ?? '') ??
            DateTime.now(),
        status: RouteStatus.fromKey(map['status'] as String?),
        currentSedeIndex: (map['currentSedeIndex'] as num?)?.toInt() ?? 0,
        baseExitQrCode: (map['baseExitQrCode'] as String?) ?? '',
        baseCloseQrCode: (map['baseCloseQrCode'] as String?) ?? '',
        pendingSync: (map['pendingSync'] as bool?) ?? false,
        sedes: (((map['sedes'] as List?) ?? [])
            .map((e) =>
                SedeModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order))),
      );
}
