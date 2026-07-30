import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aqua_life/core/theme/theme_mode.dart';

void main() {
  group('ThemeModeNotifier Tests', () {
    test('should default to dark mode when no stored value', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final notifier = ThemeModeNotifier(prefs);

      expect(notifier.state, AppThemeMode.dark);
    });

    test('should load light mode from preferences', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
      final prefs = await SharedPreferences.getInstance();

      final notifier = ThemeModeNotifier(prefs);

      expect(notifier.state, AppThemeMode.light);
    });

    test('should load system mode from preferences', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'system'});
      final prefs = await SharedPreferences.getInstance();

      final notifier = ThemeModeNotifier(prefs);

      expect(notifier.state, AppThemeMode.auto);
    });

test('themeModeProvider should provide ThemeModeNotifier', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          themeModeProvider.overrideWith((ref) => ThemeModeNotifier(prefs)),
        ],
      );

      final notifier = container.read(themeModeProvider.notifier);
      expect(notifier, isA<ThemeModeNotifier>());

      container.dispose();
    });
  });
}
