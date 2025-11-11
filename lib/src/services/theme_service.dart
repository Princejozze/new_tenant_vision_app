import 'package:flutter/material.dart';

class ThemeService extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  void useSystem() => setMode(ThemeMode.system);
  void useLight() => setMode(ThemeMode.light);
  void useDark() => setMode(ThemeMode.dark);

  void cycleMode() {
    // Cycle: system -> light -> dark -> system
    switch (_mode) {
      case ThemeMode.system:
        _mode = ThemeMode.light;
        break;
      case ThemeMode.light:
        _mode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _mode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }
}
