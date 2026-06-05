import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:aqua_life/core/shared_prefs/user_shared_prefs.dart';
import 'package:aqua_life/features/auth/presentation/pages/login_page.dart';

final onboardingViewModelProvider = StateNotifierProvider<OnboardingViewModel, void>((ref) {
  return OnboardingViewModel(
    userSharedPrefs: ref.watch(userSharedPrefsProvider),
  );
});

class OnboardingViewModel extends StateNotifier<void> {
  final UserSharedPrefs _userSharedPrefs;

  OnboardingViewModel({required UserSharedPrefs userSharedPrefs})
      : _userSharedPrefs = userSharedPrefs,
        super(null);

  Future<void> completeOnboarding(BuildContext context, {int initialLoginIndex = 0}) async {
    await _userSharedPrefs.setFirstTime(false);

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }
}
