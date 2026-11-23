import 'package:flutter/material.dart';

import '../services/vault_storage.dart';

/// Lab 11: holds the current theme. Starts with the value that main()
/// already read from disk -> no white flash when the app opens in dark mode.
class ThemeController extends ChangeNotifier {
  final VaultStorage _storage;
  bool _isDark;

  ThemeController(this._storage) : _isDark = _storage.isDarkMode;

  bool get isDark => _isDark;
  ThemeMode get mode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> setDark(bool value) async {
    _isDark = value;
    notifyListeners(); // instant UI update
    await _storage.setDarkMode(value); // then persist
  }
}
