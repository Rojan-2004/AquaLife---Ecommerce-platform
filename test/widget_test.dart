import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aqua_life/app/app.dart';
import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:aqua_life/core/shared_prefs/user_shared_prefs.dart';
import 'package:aqua_life/core/services/storage/user_session_service.dart';
import 'package:aqua_life/features/splash/presentation/pages/splash_page.dart';
import 'package:aqua_life/features/splash/presentation/view_model/splash_view_model.dart';
import 'package:aqua_life/core/theme/theme_mode.dart';

class MockUserSharedPrefs extends Mock implements UserSharedPrefs {}

class MockUserSessionService extends Mock implements UserSessionService {}

class MockSplashViewModel extends SplashViewModel {
  MockSplashViewModel()
      : super(
          userSharedPrefs: MockUserSharedPrefs(),
        );

  @override
  Future<void> init(BuildContext context) async {}
}

class MockThemePrefs extends Mock implements SharedPreferences {}

Widget pumpApp() {
  return ProviderScope(
    overrides: [
      userSharedPrefsProvider.overrideWithValue(MockUserSharedPrefs()),
      userSessionServiceProvider.overrideWithValue(MockUserSessionService()),
      splashViewModelProvider.overrideWith((ref) => MockSplashViewModel()),
      themeModeProvider.overrideWith((ref) {
        final prefs = MockThemePrefs();
        when(() => prefs.getString(any())).thenReturn(null);
        return ThemeModeNotifier(prefs);
      }),
    ],
    child: const App(),
  );
}

void main() {
  group('Widget Tests', () {
    testWidgets('App should build without errors', (tester) async {
      await tester.pumpWidget(pumpApp());
      expect(find.byType(App), findsOneWidget);
    });

    testWidgets('App should have title AquaLife', (tester) async {
      await tester.pumpWidget(pumpApp());
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp).first);
      expect(app.title, 'AquaLife');
    });

    testWidgets('App should disable debug banner', (tester) async {
      await tester.pumpWidget(pumpApp());
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp).first);
      expect(app.debugShowCheckedModeBanner, false);
    });

    testWidgets('App should use AppTheme.lightTheme', (tester) async {
      await tester.pumpWidget(pumpApp());
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp).first);
      expect(app.theme, AppTheme.lightTheme);
    });

    testWidgets('App should show SplashPage as home', (tester) async {
      await tester.pumpWidget(pumpApp());
      expect(find.byType(SplashPage), findsOneWidget);
    });

    testWidgets('AppTheme.lightTheme should have correct primary color',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(),
        ),
      );
      final theme =
          Theme.of(tester.element(find.byType(Scaffold)));
      expect(theme.primaryColor, AppTheme.lightTheme.primaryColor);
    });

    testWidgets('AppTheme.lightTheme should have correct background color',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(),
        ),
      );
      await tester.pump();
      final scaffoldColor =
          Theme.of(tester.element(find.byType(Scaffold))).scaffoldBackgroundColor;
      expect(scaffoldColor, AppTheme.lightTheme.scaffoldBackgroundColor);
    });

    testWidgets('AppTheme.lightTheme should have correct font family',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Text('Test'),
          ),
        ),
      );
      final textStyle = DefaultTextStyle.of(tester.element(find.byType(Text)));
      expect(textStyle.style.fontFamily, 'OpenSans');
    });

    testWidgets('AppBar should have transparent background',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
          ),
        ),
      );
      final appBarTheme =
          AppTheme.lightTheme.appBarTheme;
      expect(appBarTheme.backgroundColor, Colors.transparent);
    });
  });
}
