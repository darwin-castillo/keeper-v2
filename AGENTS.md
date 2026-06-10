# Keeper — Agent Instructions

## Stack
- Flutter 3.44.0 / Dart 3.12.0
- **Provider** (state management), **Hive** (offline persistence, no codegen), **mobile_scanner** (QR), **url_launcher** (maps), **intl** (es_MX locale)

## Architecture
```
lib/
  core/        # Theme (KeeperColors, KeeperTheme), enums (RouteStatus, SedeStatus), utils, errors
  data/        # Hive datasource, models (toMap/fromMap), repo impl, seed data
  domain/      # RouteRepository interface (abstract interface class)
  presentation/ # Providers (ChangeNotifier) + Screens + Widgets
```

## Key commands
```bash
flutter pub get          # Resolve dependencies
flutter run              # Run on device/emulator
flutter build apk --debug # Android APK build
dart analyze             # Static analysis (lint + typecheck)
flutter test             # Smoke test (single test)
```

## Quirks
- **macOS quarantine**: If `android/gradlew` fails with "operation not permitted", remove the quarantine attribute: `xattr -d com.apple.quarantine android/gradlew`
- **Stale analysis cache**: If Flutter SDK types (Container, BuildContext, Icons, etc.) are suddenly "not defined", run `flutter clean && flutter pub get` to regenerate `.dart_tool/package_config.json`
- **No codegen**: Hive stores plain maps (JSON-friendly), no TypeAdapters needed
- **Locale**: `initializeDateFormatting('es_MX')` is called in `main()` — tests requiring date formatting may need this too

## State machine
Route status flow: `enBase → rutaVerificada → rutaIniciada → rutaPorFinalizar → finalizada`

Gates in `RouteProvider`:
- `canVerifyPackages` → only in `enBase`
- `canScanBaseExit` → only in `rutaVerificada`
- `canOperateSedes` / `canCheckInCurrentSede` → only in `rutaIniciada`
- `canFinalize` → only in `rutaPorFinalizar`

## Demo test codes (no camera needed)
- Base exit: `KEEPER-BASE-EXIT`
- Base close: `KEEPER-BASE-CLOSE`
- Sede QR: `KEEPER-SEDE-1` … `KEEPER-SEDE-6`
- Package codes: `PK-1001`, `PK-1002`, `PK-3204`, `PK-3210`, `PK-9912`, `PK-9945`, `PK-1052`, `PK-7781`, `PK-8830`

## Design conventions
- Dark mode dominant (`ThemeMode.dark`), Tech Purple brand (`KeeperColors.primary = #5319F4`)
- High contrast, OLED-friendly, sunlight-readable
- All new widgets should use `KeeperColors` / `KeeperTheme` tokens
- Cards use `KeeperCard` wrapper for consistent border radius + accent stripe
- Snackbars use `Snack` utility (branded colors, floating, 2s duration)

## Testing
- Single smoke test in `test/widget_test.dart` — verifies login screen renders
- No unit tests yet for `RouteProvider`; manual verification via demo codes
