import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide light/dark selection, persisted across launches.
/// Defaults to dark - the app's established look.
class ThemeProvider extends ChangeNotifier {
  static const String _prefsKey = 'app_theme_mode';

  ThemeProvider(this._sharedPreferences) {
    final stored = _sharedPreferences.getString(_prefsKey);
    _themeMode = stored == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  final SharedPreferences _sharedPreferences;

  late ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> toggle() => setDark(!isDark);

  Future<void> setDark(bool dark) async {
    final next = dark ? ThemeMode.dark : ThemeMode.light;
    if (next == _themeMode) return;
    _themeMode = next;
    notifyListeners();
    await _sharedPreferences.setString(_prefsKey, dark ? 'dark' : 'light');
  }
}
