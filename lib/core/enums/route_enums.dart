/// Centralized enums that drive the Keeper operational state machine.
///
/// These are intentionally framework-agnostic (pure Dart) so they can be
/// reused across the domain, data and presentation layers without coupling.
library;

/// Operational status of the driver/route. Controls which actions the UI
/// is allowed to expose at any given moment.
enum RouteStatus {
  /// Initial state. The route is assigned but the driver is still at base.
  enBase,

  /// All manifest packages were verified (scanned) at base. The driver is
  /// cleared to scan the base-exit QR.
  rutaVerificada,

  /// The base-exit QR was scanned. The driver is in transit and can operate
  /// at each sede in strict order.
  rutaIniciada,

  /// Every sede has been processed. The driver must return to base.
  rutaPorFinalizar,

  /// The closing QR was scanned at base. The route is closed.
  finalizada;

  /// Human readable label used in the UI.
  String get label => switch (this) {
    RouteStatus.enBase => 'En base',
    RouteStatus.rutaVerificada => 'Ruta verificada',
    RouteStatus.rutaIniciada => 'Ruta iniciada',
    RouteStatus.rutaPorFinalizar => 'Por finalizar',
    RouteStatus.finalizada => 'Finalizada',
  };

  /// Technical UPPER_SNAKE code shown in status pills (e.g. `RUTA_INICIADA`).
  String get code => switch (this) {
    RouteStatus.enBase => 'EN_BASE',
    RouteStatus.rutaVerificada => 'RUTA_VERIFICADA',
    RouteStatus.rutaIniciada => 'RUTA_INICIADA',
    RouteStatus.rutaPorFinalizar => 'RUTA_POR_FINALIZAR',
    RouteStatus.finalizada => 'FINALIZADA',
  };

  /// Stable key for persistence (decoupled from enum index ordering).
  String get key => name;

  static RouteStatus fromKey(String? key) => RouteStatus.values.firstWhere(
    (e) => e.name == key,
    orElse: () => RouteStatus.enBase,
  );
}

/// Lifecycle of an individual sede (branch/stop) within the route.
enum SedeStatus {
  pending,
  inProcess,
  completed;

  String get label => switch (this) {
    SedeStatus.pending => 'Pendiente',
    SedeStatus.inProcess => 'En proceso',
    SedeStatus.completed => 'Completada',
  };

  String get key => name;

  static SedeStatus fromKey(String? key) => SedeStatus.values.firstWhere(
    (e) => e.name == key,
    orElse: () => SedeStatus.pending,
  );
}

/// Type of operation performed at a sede.
enum SedeOperationType {
  /// Only drop-off of pre-loaded packages.
  entrega,

  /// Only pick-up of new packages (scanned on site).
  retiro,

  /// Both drop-off and pick-up.
  mixto;

  String get label => switch (this) {
    SedeOperationType.entrega => 'Entrega',
    SedeOperationType.retiro => 'Retiro',
    SedeOperationType.mixto => 'Mixto',
  };

  bool get allowsDelivery =>
      this == SedeOperationType.entrega || this == SedeOperationType.mixto;

  bool get allowsPickup =>
      this == SedeOperationType.retiro || this == SedeOperationType.mixto;

  String get key => name;

  static SedeOperationType fromKey(String? key) =>
      SedeOperationType.values.firstWhere(
        (e) => e.name == key,
        orElse: () => SedeOperationType.entrega,
      );
}

/// Whether a package is delivered to a sede or picked up from it.
enum PackageType {
  /// Pre-loaded package to be delivered (drop-off).
  entrega,

  /// Package picked up on site (created during the operation).
  retiro;

  String get label => switch (this) {
    PackageType.entrega => 'Entrega',
    PackageType.retiro => 'Retiro',
  };

  String get key => name;

  static PackageType fromKey(String? key) => PackageType.values.firstWhere(
    (e) => e.name == key,
    orElse: () => PackageType.entrega,
  );
}
