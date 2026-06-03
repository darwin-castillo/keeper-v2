# Keeper

Aplicación móvil corporativa de movilidad logística para operadores/conductores en ruta.
Diseño dark-mode de alto contraste, offline-first y máquina de estados estricta del flujo de ruta.

## Stack

- **Flutter** (Material 3, dark mode dominante)
- **Provider** como gestor de estado oficial del MVP
- **Hive** para persistencia local offline-first (serialización JSON, sin codegen)
- **mobile_scanner** para escaneo de códigos de barras / QR
- **url_launcher** para navegación externa (Google/Apple Maps)
- **intl** para formato de moneda y fechas (es_MX)

## Arquitectura (Clean Architecture)

```
lib/
  core/        # Tema (KeeperTheme/KeeperColors), enums, utils, errores
  data/        # Modelos, datasource local (Hive), repositorios, seed
  domain/      # Contratos de repositorio (interfaces)
  presentation/# Providers (estado) + screens + widgets de marca
```

## Flujo operativo (RouteStatus)

`enBase` -> `rutaVerificada` -> `rutaIniciada` -> `rutaPorFinalizar` -> `finalizada`

1. **Login** del operador.
2. **Dashboard** dinámico con acción principal según el estado.
3. **Iniciar ruta**: verificación de manifiesto por código de barras + QR de salida de base.
4. **Estado de la ruta**: línea de tiempo enumerada de sedes en orden estricto + mapa a la siguiente.
5. **Operación en sede**: check-in por QR, entregas (check verde) y/o retiros (con monto).
6. **Finalizar ruta**: resumen y QR de cierre en base.

## Datos de demo

En el primer arranque se siembra una ruta de ejemplo. Códigos esperados:

- QR salida de base: `KEEPER-BASE-EXIT`
- QR cierre en base: `KEEPER-BASE-CLOSE`
- QR sedes: `KEEPER-SEDE-1` … `KEEPER-SEDE-6`
- Códigos de paquetes (entrega): `PK-1001`, `PK-1002`, `PK-3204`, `PK-3210`, `PK-9912`, `PK-9945`, `PK-1052`, `PK-7781`, `PK-8830`

En las pantallas de captura QR puedes usar **"Ingresar código manualmente"** para probar sin cámara (emulador).

## Ejecutar

```bash
flutter pub get
flutter run
```

Requiere permisos de cámara (ya configurados en Android e iOS).
