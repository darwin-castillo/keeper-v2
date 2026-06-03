import '../../core/enums/route_enums.dart';
import '../models/package_model.dart';
import '../models/route_model.dart';
import '../models/sede_model.dart';

/// Generates a deterministic sample route for the MVP / demo.
///
/// In production this would be replaced by a remote fetch synced into the
/// local store. QR codes here are the *expected* values the driver scans.
abstract final class RouteSeedData {
  static RouteModel buildFor(String driverId) {
    final today = DateTime.now();

    return RouteModel(
      id: 'route-${today.toIso8601String().substring(0, 10)}',
      code: 'KPR-${today.year}-0481',
      driverId: driverId,
      assignedDate: today,
      baseExitQrCode: 'KEEPER-BASE-EXIT',
      baseCloseQrCode: 'KEEPER-BASE-CLOSE',
      status: RouteStatus.enBase,
      currentSedeIndex: 0,
      sedes: [
        SedeModel(
          id: 'sede-1',
          name: 'Sucursal Centro',
          address: 'Av. Reforma 122, Centro',
          order: 1,
          latitude: 19.4326,
          longitude: -99.1332,
          operationType: SedeOperationType.entrega,
          checkInQrCode: 'KEEPER-SEDE-1',
          packages: const [
            PackageModel(
              id: 'pkg-101',
              code: '7501234500101',
              description: 'Sobre documentos legales',
              amount: 0,
              type: PackageType.entrega,
              sedeId: 'sede-1',
            ),
            PackageModel(
              id: 'pkg-102',
              code: '7501234500102',
              description: 'Caja mediana - refacciones',
              amount: 1850.00,
              type: PackageType.entrega,
              sedeId: 'sede-1',
            ),
          ],
        ),
        SedeModel(
          id: 'sede-2',
          name: 'Plaza Polanco',
          address: 'Av. Masaryk 360, Polanco',
          order: 2,
          latitude: 19.4333,
          longitude: -99.1900,
          operationType: SedeOperationType.mixto,
          checkInQrCode: 'KEEPER-SEDE-2',
          packages: const [
            PackageModel(
              id: 'pkg-201',
              code: '7501234500201',
              description: 'Paquete electrónica',
              amount: 4200.00,
              type: PackageType.entrega,
              sedeId: 'sede-2',
            ),
          ],
        ),
        SedeModel(
          id: 'sede-3',
          name: 'Bodega Sur',
          address: 'Calz. de Tlalpan 1500, Sur',
          order: 3,
          latitude: 19.3600,
          longitude: -99.1400,
          operationType: SedeOperationType.retiro,
          checkInQrCode: 'KEEPER-SEDE-3',
          packages: const [],
        ),
      ],
    );
  }
}
