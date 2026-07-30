import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aqua_life/app/app.dart';
import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:aqua_life/core/shared_prefs/user_shared_prefs.dart';
import 'package:aqua_life/core/services/storage/user_session_service.dart';
import 'package:aqua_life/core/theme/theme_mode.dart';
import 'package:aqua_life/features/auth/presentation/pages/login_page.dart';
import 'package:aqua_life/features/auth/presentation/pages/register_page.dart';
import 'package:aqua_life/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:aqua_life/features/splash/presentation/pages/splash_page.dart';
import 'package:aqua_life/features/splash/presentation/view_model/splash_view_model.dart';

class MockUserSharedPrefs extends Mock implements UserSharedPrefs {}

class MockUserSessionService extends Mock implements UserSessionService {}

class MockThemePrefs extends Mock implements SharedPreferences {}

Widget pumpApp() {
  return ProviderScope(
    overrides: [
      userSharedPrefsProvider.overrideWithValue(MockUserSharedPrefs()),
      userSessionServiceProvider.overrideWithValue(MockUserSessionService()),
      splashViewModelProvider.overrideWith((ref) {
        final prefs = MockUserSharedPrefs();
        when(() => prefs.getFirstTime()).thenAnswer((_) async => false);
        return SplashViewModel(userSharedPrefs: prefs);
      }),
      themeModeProvider.overrideWith((ref) {
        final prefs = MockThemePrefs();
        when(() => prefs.getString(any())).thenReturn(null);
        return ThemeModeNotifier(prefs);
      }),
    ],
    child: const App(),
  );
}

Widget pumpLoginPage() {
  return ProviderScope(
    overrides: [
      userSharedPrefsProvider.overrideWithValue(MockUserSharedPrefs()),
      userSessionServiceProvider.overrideWithValue(MockUserSessionService()),
      themeModeProvider.overrideWith((ref) {
        final prefs = MockThemePrefs();
        when(() => prefs.getString(any())).thenReturn(null);
        return ThemeModeNotifier(prefs);
      }),
    ],
    child: const MaterialApp(home: LoginPage()),
  );
}

Widget pumpDashboardApp() {
  return ProviderScope(
    overrides: [
      userSharedPrefsProvider.overrideWithValue(MockUserSharedPrefs()),
      userSessionServiceProvider.overrideWithValue(MockUserSessionService()),
      themeModeProvider.overrideWith((ref) {
        final prefs = MockThemePrefs();
        when(() => prefs.getString(any())).thenReturn(null);
        return ThemeModeNotifier(prefs);
      }),
    ],
    child: const MaterialApp(home: DashboardPage()),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration Tests', () {
    testWidgets('App should launch and display splash screen', (tester) async {
      await tester.pumpWidget(pumpApp());
      expect(find.byType(SplashPage), findsOneWidget);
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

    testWidgets('App should use light theme by default', (tester) async {
      await tester.pumpWidget(pumpApp());
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp).first);
      expect(app.theme, AppTheme.lightTheme);
    });

    testWidgets('Login page should display email and password fields', (tester) async {
      await tester.pumpWidget(pumpLoginPage());
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outlined), findsOneWidget);
    });

    testWidgets('Login page should have Continue with social login section', (tester) async {
      await tester.pumpWidget(pumpLoginPage());
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Continue with'), findsOneWidget);
      expect(find.byIcon(Icons.g_mobiledata), findsOneWidget);
    });

    testWidgets('Tapping Sign Up navigates to register page', (tester) async {
      await tester.pumpWidget(pumpLoginPage());
      await tester.pumpAndSettle();
      final signUpFinder = find.text('Sign Up');
      await tester.ensureVisible(signUpFinder);
      await tester.tap(signUpFinder);
      await tester.pumpAndSettle();
      expect(find.byType(RegisterPage), findsOneWidget);
    });

    testWidgets('Register page should display Sign Up button', (tester) async {
      await tester.pumpWidget(pumpLoginPage());
      await tester.pumpAndSettle();
      final signUpFinder = find.text('Sign Up');
      await tester.ensureVisible(signUpFinder);
      await tester.tap(signUpFinder);
      await tester.pumpAndSettle();
      expect(find.byType(RegisterPage), findsOneWidget);
      expect(find.text('Sign Up'), findsAtLeast(1));
    });

    testWidgets('Register page should have all input fields', (tester) async {
      await tester.pumpWidget(pumpLoginPage());
      await tester.pumpAndSettle();
      final signUpFinder = find.text('Sign Up');
      await tester.ensureVisible(signUpFinder);
      await tester.tap(signUpFinder);
      await tester.pumpAndSettle();
      expect(find.byType(RegisterPage), findsOneWidget);
      expect(find.byIcon(Icons.person_outlined), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outlined), findsAtLeast(1));
    });

    testWidgets('Dashboard page should display with bottom navigation bar', (tester) async {
      await tester.pumpWidget(pumpDashboardApp());
      await tester.pumpAndSettle();
      expect(find.byType(DashboardPage), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('Dashboard should have Home tab selected by default', (tester) async {
      await tester.pumpWidget(pumpDashboardApp());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsNothing);
    });

    testWidgets('Dashboard bottom navigation has Home, Cart, Assistant, Profile tabs', (tester) async {
      await tester.pumpWidget(pumpDashboardApp());
      await tester.pumpAndSettle();
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Cart'), findsOneWidget);
      expect(find.text('Assistant'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Tapping Cart tab switches to Cart view', (tester) async {
      await tester.pumpWidget(pumpDashboardApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cart'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    });

    testWidgets('Tapping Assistant tab switches to Assistant view', (tester) async {
      await tester.pumpWidget(pumpDashboardApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Assistant'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.smart_toy), findsOneWidget);
    });

    testWidgets('Tapping Profile tab switches to Profile view', (tester) async {
      await tester.pumpWidget(pumpDashboardApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('Tapping Home tab switches back to Home view', (tester) async {
      await tester.pumpWidget(pumpDashboardApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cart'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('Login page should have "Don\'t have an account?" link', (tester) async {
      await tester.pumpWidget(pumpLoginPage());
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text("Don't have an account? "), findsOneWidget);
    });

    testWidgets('Register page should have name, email, and password fields', (tester) async {
      await tester.pumpWidget(pumpLoginPage());
      await tester.pumpAndSettle();
      final signUpFinder = find.text('Sign Up');
      await tester.ensureVisible(signUpFinder);
      await tester.tap(signUpFinder);
      await tester.pumpAndSettle();
      expect(find.byType(RegisterPage), findsOneWidget);
      expect(find.byIcon(Icons.person_outlined), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outlined), findsAtLeast(1));
    });

    testWidgets('App should have debug banner disabled', (tester) async {
      await tester.pumpWidget(pumpApp());
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp).first);
      expect(app.debugShowCheckedModeBanner, false);
    });

    testWidgets('Login page should have password input with lock icon', (tester) async {
      await tester.pumpWidget(pumpLoginPage());
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byIcon(Icons.lock_outlined), findsOneWidget);
    });
  });
}