import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aqua_life/core/services/light/light_sensor_service.dart';
import 'package:aqua_life/core/services/storage/user_session_service.dart';

enum AppThemeMode { light, dark, auto }

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) {
  return ThemeModeNotifier(ref.read(sharedPreferencesProvider));
});

final effectiveThemeModeProvider = Provider<ThemeMode>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  switch (themeMode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.auto:
      final luxAsync = ref.watch(luxStreamProvider);
      return luxAsync.when(
        data: (lux) => lux <= 10 ? ThemeMode.dark : ThemeMode.light,
        loading: () => ThemeMode.system,
        error: (_, __) => ThemeMode.system,
      );
  }
});

class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  final SharedPreferences _prefs;
  static const String _keyThemeMode = 'theme_mode';

  ThemeModeNotifier(this._prefs) : super(AppThemeMode.dark) {
    _loadThemeMode();
  }

  void _loadThemeMode() {
    final stored = _prefs.getString(_keyThemeMode);
    if (stored == 'light') {
      state = AppThemeMode.light;
    } else if (stored == 'dark') {
      state = AppThemeMode.dark;
    } else if (stored == 'auto') {
      state = AppThemeMode.auto;
    } else {
      state = AppThemeMode.dark;
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    final value = mode == AppThemeMode.light
        ? 'light'
        : mode == AppThemeMode.dark
            ? 'dark'
            : 'auto';
    await _prefs.setString(_keyThemeMode, value);
  }
}
