import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _silent = false;
  bool _useOz = false;
  bool _btConnected = false;
  String _userName = 'Ela Demir';

  bool get silent => _silent;
  bool get useOz => _useOz;
  bool get btConnected => _btConnected;
  String get userName => _userName;
  String get userInitial => _userName.isNotEmpty ? _userName[0].toUpperCase() : 'E';

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _silent = prefs.getBool('silent') ?? false;
    _useOz = prefs.getBool('useOz') ?? false;
    notifyListeners();
  }

  Future<void> toggleSilent() async {
    _silent = !_silent;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('silent', _silent);
    notifyListeners();
  }

  Future<void> toggleUnit() async {
    _useOz = !_useOz;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useOz', _useOz);
    notifyListeners();
  }

  void toggleBluetooth() {
    _btConnected = !_btConnected;
    notifyListeners();
  }

  void setUserName(String name) {
    if (name.trim().isEmpty) return;
    _userName = name.trim();
    notifyListeners();
  }

  String formatMl(int ml) {
    if (_useOz) {
      final oz = (ml / 29.5735).toStringAsFixed(1);
      return '$oz oz';
    }
    return '$ml ml';
  }
}
