import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:aqua_life/core/shared_prefs/user_shared_prefs.dart';
import 'package:aqua_life/core/services/storage/user_session_service.dart';
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
      if (_userSessionService.isLoggedIn()) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }
}
