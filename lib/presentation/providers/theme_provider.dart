import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/keeper_theme.dart';

/// Manages the app's [ThemeMode] and syncs the system UI overlay.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;
  bool get isDarkMode => _mode == ThemeMode.dark;

  void setDarkMode(bool dark) {
    _mode = dark ? ThemeMode.dark : ThemeMode.light;
    SystemChrome.setSystemUIOverlayStyle(
      dark ? KeeperTheme.systemOverlayDark : KeeperTheme.systemOverlayLight,
    );
    notifyListeners();
  }

  void toggle() => setDarkMode(!isDarkMode);
}
