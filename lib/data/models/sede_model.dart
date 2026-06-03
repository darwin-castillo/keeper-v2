import '../../core/enums/route_enums.dart';
import 'package_model.dart';

/// A sede (branch/stop) to be visited within a route.
///
/// Sedes are processed in a strict chronological order defined by [order].
class SedeModel {
  final String id;
  final String name;
  final String address;

  /// 1-based position in the route (strict cronological order).
  final int order;

  final double latitude;
  final double longitude;

  /// What the driver does here: entrega, retiro or mixto.
  final SedeOperationType operationType;

  /// Current lifecycle status.
  final SedeStatus status;

  /// Expected value of the physical QR at the sede entrance (check-in).
  final String checkInQrCode;

  /// Packages associated with this sede.
  final List<PackageModel> packages;

  /// Timestamp the driver checked in (for sync/audit).
  final DateTime? checkedInAt;

  const SedeModel({
    required this.id,
    required this.name,
    required this.address,
    required this.order,
    required this.latitude,
    required this.longitude,
    required this.operationType,
    required this.checkInQrCode,
    this.status = SedeStatus.pending,
    this.packages = const [],
    this.checkedInAt,
  });

  // --- Derived helpers ---------------------------------------------------

  List<PackageModel> get deliveryPackages =>
      packages.where((p) => p.type == PackageType.entrega).toList();

  List<PackageModel> get pickupPackages =>
      packages.where((p) => p.type == PackageType.retiro).toList();

  /// Delivery is satisfied when every drop-off package was scanned on site.
  bool get isDeliveryComplete =>
      deliveryPackages.every((p) => p.isScanned);

  /// Total value picked up at this sede.
  double get pickupTotal =>
      pickupPackages.fold(0.0, (sum, p) => sum + p.amount);

  /// Total value delivered (scanned) at this sede.
  double get deliveredTotal => deliveryPackages
      .where((p) => p.isScanned)
      .fold(0.0, (sum, p) => sum + p.amount);

  SedeModel copyWith({
    SedeStatus? status,
    List<PackageModel>? packages,
    DateTime? checkedInAt,
  }) {
    return SedeModel(
      id: id,
      name: name,
      address: address,
      order: order,
      latitude: latitude,
      longitude: longitude,
      operationType: operationType,
      checkInQrCode: checkInQrCode,
      status: status ?? this.status,
      packages: packages ?? this.packages,
      checkedInAt: checkedInAt ?? this.checkedInAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'address': address,
        'order': order,
        'latitude': latitude,
        'longitude': longitude,
        'operationType': operationType.key,
        'status': status.key,
        'checkInQrCode': checkInQrCode,
        'checkedInAt': checkedInAt?.toIso8601String(),
        'packages': packages.map((p) => p.toMap()).toList(),
      };

  factory SedeModel.fromMap(Map<String, dynamic> map) => SedeModel(
        id: map['id'] as String,
        name: map['name'] as String,
        address: (map['address'] as String?) ?? '',
        order: (map['order'] as num?)?.toInt() ?? 0,
        latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
        operationType:
            SedeOperationType.fromKey(map['operationType'] as String?),
        status: SedeStatus.fromKey(map['status'] as String?),
        checkInQrCode: (map['checkInQrCode'] as String?) ?? '',
        checkedInAt: map['checkedInAt'] == null
            ? null
            : DateTime.tryParse(map['checkedInAt'] as String),
        packages: ((map['packages'] as List?) ?? [])
            .map((e) => PackageModel.fromMap(
                Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  @override
  bool operator ==(Object other) => other is SedeModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
