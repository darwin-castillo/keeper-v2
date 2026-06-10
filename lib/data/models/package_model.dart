import '../../core/enums/route_enums.dart';

/// A single package handled during the route.
///
/// Designed for offline-first persistence: it serializes to a plain
/// `Map<String, dynamic>` (JSON-friendly) so it can be stored in any local
/// engine (Hive, SQLite, Isar) and synced when connectivity returns.
class PackageModel {
  /// Stable unique identifier (server id, or local UUID for on-site pickups).
  final String id;

  /// Scannable barcode value printed on the package.
  final String code;

  /// Short human description shown in the UI.
  final String description;

  /// Monetary value associated with the package.
  final double amount;

  /// Physical location reference at the sede (e.g. `Bin A-12`, `Counter`).
  final String binLocation;

  /// Whether this package is a delivery (drop-off) or a pickup.
  final PackageType type;

  /// Id of the sede this package belongs to (or empty for a base-only item).
  final String sedeId;

  /// Verified during the base load/check-out (manifest verification).
  final bool verifiedInBase;

  /// Scanned/checked at the sede (delivered, or registered on pickup).
  final bool isScanned;

  /// Timestamp of the on-site scan (for sync/audit).
  final DateTime? scannedAt;

  /// True if created offline and pending sync to the backend.
  final bool pendingSync;

  /// Comprobante (receipt/document) this package was scanned under.
  final String? comprobanteCode;

  const PackageModel({
    required this.id,
    required this.code,
    required this.description,
    required this.amount,
    required this.type,
    required this.sedeId,
    this.binLocation = '',
    this.verifiedInBase = false,
    this.isScanned = false,
    this.scannedAt,
    this.pendingSync = false,
    this.comprobanteCode,
  });

  PackageModel copyWith({
    String? description,
    double? amount,
    String? binLocation,
    bool? verifiedInBase,
    bool? isScanned,
    DateTime? scannedAt,
    bool? pendingSync,
    String? comprobanteCode,
  }) {
    return PackageModel(
      id: id,
      code: code,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type,
      sedeId: sedeId,
      binLocation: binLocation ?? this.binLocation,
      verifiedInBase: verifiedInBase ?? this.verifiedInBase,
      isScanned: isScanned ?? this.isScanned,
      scannedAt: scannedAt ?? this.scannedAt,
      pendingSync: pendingSync ?? this.pendingSync,
      comprobanteCode: comprobanteCode ?? this.comprobanteCode,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'code': code,
    'description': description,
    'amount': amount,
    'binLocation': binLocation,
    'type': type.key,
    'sedeId': sedeId,
    'verifiedInBase': verifiedInBase,
    'isScanned': isScanned,
    'scannedAt': scannedAt?.toIso8601String(),
    'pendingSync': pendingSync,
    'comprobanteCode': comprobanteCode,
  };

  factory PackageModel.fromMap(Map<String, dynamic> map) => PackageModel(
    id: map['id'] as String,
    code: map['code'] as String,
    description: (map['description'] as String?) ?? '',
    amount: (map['amount'] as num?)?.toDouble() ?? 0,
    binLocation: (map['binLocation'] as String?) ?? '',
    type: PackageType.fromKey(map['type'] as String?),
    sedeId: (map['sedeId'] as String?) ?? '',
    verifiedInBase: (map['verifiedInBase'] as bool?) ?? false,
    isScanned: (map['isScanned'] as bool?) ?? false,
    scannedAt: map['scannedAt'] == null
        ? null
        : DateTime.tryParse(map['scannedAt'] as String),
    pendingSync: (map['pendingSync'] as bool?) ?? false,
    comprobanteCode: map['comprobanteCode'] as String?,
  );

  @override
  bool operator ==(Object other) => other is PackageModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
