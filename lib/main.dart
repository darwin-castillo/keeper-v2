import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart'
    show HashUrlStrategy, setUrlStrategy;
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/theme/keeper_theme.dart';
import 'data/datasources/keeper_local_datasource.dart';
import 'data/repositories/route_repository_impl.dart';
import 'domain/repositories/route_repository.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/route_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KeeperLocalDataSource.init();
  await initializeDateFormatting('es_MX', null);
  SystemChrome.setSystemUIOverlayStyle(KeeperTheme.systemOverlay);
  setUrlStrategy(const HashUrlStrategy());
  runApp(const KeeperApp());
}

class KeeperApp extends StatelessWidget {
  const KeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    final RouteRepository repository = RouteRepositoryImpl(
      KeeperLocalDataSource(),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => RouteProvider(repository)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, theme, _) => MaterialApp(
          title: 'Keeper',
          debugShowCheckedModeBanner: false,
          theme: KeeperTheme.light,
          darkTheme: KeeperTheme.dark,
          themeMode: theme.mode,
          home: const _Root(),
        ),
      ),
    );
  }
}

/// Swaps between login and dashboard based on authentication state.
class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.select<AuthProvider, bool>(
      (a) => a.isAuthenticated,
    );
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isAuthenticated ? const MainShell() : const LoginScreen(),
    );
  }
}
