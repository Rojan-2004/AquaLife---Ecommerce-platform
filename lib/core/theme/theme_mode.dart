import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aqua_life/core/services/light/light_sensor_service.dart';
import 'package:aqua_life/core/services/storage/user_session_service.dart';

enum AppThemeMode { light, dark, auto }

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) {
  return ThemeModeNotifier(ref.read(sharedPreferencesProvider));
});

class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  final SharedPreferences _prefs;
  static const String _keyThemeMode = 'theme_mode';
  StreamSubscription<int>? _luxSubscription;
  DateTime? _lastSwitchTime;

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

  ThemeMode toMaterialThemeMode() {
    switch (state) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.auto:
        return ThemeMode.system;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  void listenToLightSensor(dynamic ref) {
    _luxSubscription?.cancel();
    final service = LightSensorService();
    _luxSubscription = service.getLuxStream().listen((lux) {
      if (state != AppThemeMode.auto) return;

      final now = DateTime.now();
      if (_lastSwitchTime != null && now.difference(_lastSwitchTime!).inSeconds < 2) {
        return;
      }

      final isDark = service.isDarkFromLux(lux);
      final target = isDark ? AppThemeMode.dark : AppThemeMode.light;
      if (target != state) {
        _lastSwitchTime = now;
        state = target;
      }
    });
  }

  @override
  void dispose() {
    _luxSubscription?.cancel();
    super.dispose();
  }
}
