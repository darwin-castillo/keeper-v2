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
      code: 'KPR-992',
      driverId: driverId,
      assignedDate: today,
      baseExitQrCode: 'KEEPER-BASE-EXIT',
      baseCloseQrCode: 'KEEPER-BASE-CLOSE',
      status: RouteStatus.enBase,
      currentSedeIndex: 0,
      sedes: [
        SedeModel(
          id: 'sede-1',
          name: 'Centro de Distribución',
          address: 'Parque Industrial Oriente, Puerta 4',
          order: 1,
          latitude: 19.4326,
          longitude: -99.1332,
          operationType: SedeOperationType.entrega,
          checkInQrCode: 'KEEPER-SEDE-1',
          packages: const [
            PackageModel(
              id: 'pkg-101',
              code: 'PK-1001',
              description: 'Sobre documentos legales',
              amount: 0,
              binLocation: 'Bin A-03',
              type: PackageType.entrega,
              sedeId: 'sede-1',
            ),
            PackageModel(
              id: 'pkg-102',
              code: 'PK-1002',
              description: 'Caja mediana · refacciones',
              amount: 1850.00,
              binLocation: 'Bin B-11',
              type: PackageType.entrega,
              sedeId: 'sede-1',
            ),
          ],
        ),
        SedeModel(
          id: 'sede-2',
          name: 'Bloque Comercial Centro',
          address: 'Calle Comercio 442, Entrada lateral',
          order: 2,
          latitude: 19.4290,
          longitude: -99.1400,
          operationType: SedeOperationType.entrega,
          checkInQrCode: 'KEEPER-SEDE-2',
          packages: const [
            PackageModel(
              id: 'pkg-201',
              code: 'PK-3204',
              description: 'Paquete textil',
              amount: 980.00,
              binLocation: 'Bin C-02',
              type: PackageType.entrega,
              sedeId: 'sede-2',
            ),
            PackageModel(
              id: 'pkg-202',
              code: 'PK-3210',
              description: 'Caja electrónica',
              amount: 4200.00,
              binLocation: 'Bin C-07',
              type: PackageType.entrega,
              sedeId: 'sede-2',
            ),
          ],
        ),
        SedeModel(
          id: 'sede-3',
          name: 'Plaza Mall',
          address: '900 Av. Salud, Andén B',
          order: 3,
          latitude: 19.3900,
          longitude: -99.1700,
          operationType: SedeOperationType.mixto,
          checkInQrCode: 'KEEPER-SEDE-3',
          packages: const [
            PackageModel(
              id: 'pkg-301',
              code: 'PK-9912',
              description: 'Caja de entrega',
              amount: 2500.00,
              binLocation: 'Bin A-12',
              type: PackageType.entrega,
              sedeId: 'sede-3',
            ),
            PackageModel(
              id: 'pkg-302',
              code: 'PK-9945',
              description: 'Sobre de entrega',
              amount: 0,
              binLocation: 'Bin B-04',
              type: PackageType.entrega,
              sedeId: 'sede-3',
            ),
            PackageModel(
              id: 'pkg-303',
              code: 'PK-1052',
              description: 'Caja de entrega',
              amount: 1320.00,
              binLocation: 'Bin A-01',
              type: PackageType.entrega,
              sedeId: 'sede-3',
            ),
          ],
        ),
        SedeModel(
          id: 'sede-4',
          name: 'Patio Logístico Harbor',
          address: 'Terminal 9, Muelle C',
          order: 4,
          latitude: 19.3600,
          longitude: -99.1400,
          operationType: SedeOperationType.retiro,
          checkInQrCode: 'KEEPER-SEDE-4',
          packages: const [],
        ),
        SedeModel(
          id: 'sede-5',
          name: 'Plaza Corporativa',
          address: '1200 Av. Innovación',
          order: 5,
          latitude: 19.3700,
          longitude: -99.1800,
          operationType: SedeOperationType.entrega,
          checkInQrCode: 'KEEPER-SEDE-5',
          packages: const [
            PackageModel(
              id: 'pkg-501',
              code: 'PK-7781',
              description: 'Paquetería corporativa',
              amount: 650.00,
              binLocation: 'Bin D-01',
              type: PackageType.entrega,
              sedeId: 'sede-5',
            ),
          ],
        ),
        SedeModel(
          id: 'sede-6',
          name: 'Sucursal Norte',
          address: 'Av. Norte 88, Bahía 3',
          order: 6,
          latitude: 19.4800,
          longitude: -99.1500,
          operationType: SedeOperationType.mixto,
          checkInQrCode: 'KEEPER-SEDE-6',
          packages: const [
            PackageModel(
              id: 'pkg-601',
              code: 'PK-8830',
              description: 'Caja de entrega',
              amount: 1500.00,
              binLocation: 'Bin E-05',
              type: PackageType.entrega,
              sedeId: 'sede-6',
            ),
          ],
        ),
      ],
    );
  }
}
