import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:aqua_life/core/shared_prefs/user_shared_prefs.dart';
import 'package:aqua_life/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:aqua_life/features/auth/presentation/pages/login_page.dart';

final splashViewModelProvider = StateNotifierProvider<SplashViewModel, void>((ref) {
  return SplashViewModel(
    userSharedPrefs: ref.watch(userSharedPrefsProvider),
  );
});

class SplashViewModel extends StateNotifier<void> {
  final UserSharedPrefs _userSharedPrefs;

  SplashViewModel({required UserSharedPrefs userSharedPrefs})
      : _userSharedPrefs = userSharedPrefs,
        super(null);

  Future<void> init(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));

    final isFirstTimeResult = await _userSharedPrefs.getFirstTime();
    
    // Add mounted check before navigation
    if (!context.mounted) return;

    isFirstTimeResult.fold(
      (failure) {
        // Fallback to onboarding if there's an error
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingPage()),
        );
      },
      (isFirstTime) {
        if (isFirstTime) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const OnboardingPage()),
          );
        } else {
          // If not first time, go to Login
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      },
    );
  }
}
