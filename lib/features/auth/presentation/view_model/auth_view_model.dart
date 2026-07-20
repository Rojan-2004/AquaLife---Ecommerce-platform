import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/features/auth/domain/entities/auth_entity.dart';
import 'package:aqua_life/features/auth/domain/usecases/login_usecase.dart';
import 'package:aqua_life/features/auth/domain/usecases/logout_usecase.dart';
import 'package:aqua_life/features/auth/domain/usecases/register_usecase.dart';
import 'package:aqua_life/features/auth/presentation/state/auth_state.dart';

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(
    loginUseCase: ref.watch(loginUsecaseProvider),
    registerUseCase: ref.watch(registerUsecaseProvider),
    logoutUseCase: ref.watch(logoutUsecaseProvider),
  );
});

class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUsecase _loginUseCase;
  final RegisterUsecase _registerUseCase;
  final LogoutUsecase _logoutUseCase;

  AuthViewModel({
    required LoginUsecase loginUseCase,
    required RegisterUsecase registerUseCase,
    required LogoutUsecase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        super(AuthState.initial());

  Future<void> login(String email, String password) async {
    debugPrint('LOGIN VM: start');
    state = state.copyWith(isLoading: true, error: null);
    final result = await _loginUseCase(LoginParams(email: email, password: password));
    debugPrint('LOGIN VM: result=$result');

    result.fold(
      (failure) {
        debugPrint('LOGIN VM: failure=${failure.message}');
        state = state.copyWith(isLoading: false, error: failure.message, isSuccess: false);
      },
      (success) {
        debugPrint('LOGIN VM: success user=${success.email}');
        state = state.copyWith(isLoading: false, error: null, isSuccess: true, user: success);
      },
    );
  }

  Future<void> register(AuthEntity entity) async {
    state = state.copyWith(isLoading: true, error: null);
    final params = RegisterParams(
      fullName: entity.fullName,
      email: entity.email,
      username: entity.username,
      password: entity.password ?? '',
      phoneNumber: entity.phoneNumber,
    );
    final result = await _registerUseCase(params);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message, isSuccess: false);
      },
      (success) {
        state = state.copyWith(isLoading: false, error: null, isSuccess: true);
      },
    );
  }

  void resetState() {
    state = AuthState.initial();
  }

  Future<void> logout() async {
    await _logoutUseCase();
    resetState();
  }
}
