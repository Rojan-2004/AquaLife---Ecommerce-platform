import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aqua_life/core/shared_prefs/user_shared_prefs.dart';
import 'package:aqua_life/core/services/storage/user_session_service.dart';
import 'package:http/http.dart' as http;
import 'package:aqua_life/app/constants/api_constants.dart';
import 'package:aqua_life/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:aqua_life/features/auth/presentation/pages/login_page.dart';
import 'package:aqua_life/features/dashboard/presentation/pages/dashboard_page.dart';

final splashViewModelProvider = StateNotifierProvider<SplashViewModel, void>((ref) {
  return SplashViewModel(
    userSharedPrefs: ref.watch(userSharedPrefsProvider),
    userSessionService: ref.watch(userSessionServiceProvider),
  );
});

class SplashViewModel extends StateNotifier<void> {
  final UserSharedPrefs _userSharedPrefs;
  final UserSessionService _userSessionService;

  SplashViewModel({
    required UserSharedPrefs userSharedPrefs,
    required UserSessionService userSessionService,
  })  : _userSharedPrefs = userSharedPrefs,
        _userSessionService = userSessionService,
        super(null);

  Future<void> init(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));

    final isFirstTime = await _userSharedPrefs.getFirstTime();

    if (!context.mounted) return;

    if (isFirstTime) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingPage()),
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      final cookie = prefs.getString('session_cookie');
      final secureStorage = const FlutterSecureStorage();
      final storedToken = await secureStorage.read(key: 'auth_token');

      final token = storedToken != null && storedToken.isNotEmpty
          ? storedToken
          : (cookie?.replaceAll('token=', '') ?? '');

      if (token.isEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        return;
      }

      try {
        final meRes = await http.get(
          Uri.parse('${ApiConstants.baseUrl}/api/v1/auth/me'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
        if (meRes.statusCode == 200) {
          await secureStorage.write(key: 'auth_token', value: token);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
          return;
        }
      } catch (_) {
        // ignore and try cookie-based session
      }

      if (cookie != null && cookie.isNotEmpty) {
        try {
          final sessionRes = await http.get(
            Uri.parse('${ApiConstants.baseUrl}/api/auth/session'),
            headers: {'Cookie': cookie},
          );
          if (sessionRes.statusCode == 200) {
            final sessionData = jsonDecode(sessionRes.body);
            final user = sessionData['user'];
            if (user != null) {
              await secureStorage.write(key: 'auth_token', value: token);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const DashboardPage()),
              );
              return;
            }
          }
        } catch (_) {
          // ignore
        }
      }

      await secureStorage.delete(key: 'auth_token');
      await prefs.remove('session_cookie');
      await prefs.remove('user_data');

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }
}
