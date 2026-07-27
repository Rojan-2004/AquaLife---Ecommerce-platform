import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aqua_life/core/shared_prefs/user_shared_prefs.dart';
import 'package:aqua_life/core/services/storage/user_session_service.dart';
import 'package:aqua_life/app/services/api_service.dart';
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
      if (cookie == null || cookie.isEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        return;
      }

      try {
        final res = await ApiService.get('/api/auth/session');
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['user'] != null) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
            return;
          }
        } else {
          // Fallback to Express backend me endpoint
          final meRes = await http.get(
            Uri.parse('${ApiConstants.baseUrl}/api/v1/auth/me'),
            headers: {
              'Cookie': cookie,
              'Authorization': 'Bearer ${cookie.replaceAll('token=', '')}'
            },
          );
          if (meRes.statusCode == 200) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
            return;
          }
        }
      } catch (_) {}

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }
}
