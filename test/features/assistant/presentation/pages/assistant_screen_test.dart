import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:aqua_life/core/theme/theme_mode.dart';
import 'package:aqua_life/features/assistant/presentation/pages/assistant_screen.dart';

void main() {
  group('AssistantScreen Theme Tests', () {
    Future<void> pumpThemedApp(WidgetTester tester, ThemeMode mode) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            themeModeProvider.overrideWith((ref) {
              return ThemeModeNotifier(prefs);
            }),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            home: const AssistantScreen(),
          ),
        ),
      );
    }

    testWidgets('should build with light theme', (tester) async {
      await pumpThemedApp(tester, ThemeMode.light);
      expect(find.byType(AssistantScreen), findsOneWidget);
    });

    testWidgets('should build with dark theme', (tester) async {
      await pumpThemedApp(tester, ThemeMode.dark);
      expect(find.byType(AssistantScreen), findsOneWidget);
    });

    testWidgets('should show app bar with AI Assistant title', (tester) async {
      await pumpThemedApp(tester, ThemeMode.light);
      expect(find.text('AI Assistant'), findsOneWidget);
    });

    testWidgets('should show text input field', (tester) async {
      await pumpThemedApp(tester, ThemeMode.light);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should show send button', (tester) async {
      await pumpThemedApp(tester, ThemeMode.light);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('should show camera button', (tester) async {
      await pumpThemedApp(tester, ThemeMode.light);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('should display initial assistant greeting', (tester) async {
      await pumpThemedApp(tester, ThemeMode.light);
      expect(find.textContaining('Aquarium Assistant'), findsOneWidget);
    });

    testWidgets('should allow entering text in input field', (tester) async {
      await pumpThemedApp(tester, ThemeMode.light);

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'test input');
      await tester.pump();

      expect(find.text('test input'), findsOneWidget);
    });
  });
}
