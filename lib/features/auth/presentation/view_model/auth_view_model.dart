import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/features/auth/domain/entities/auth_entity.dart';
import 'package:aqua_life/features/auth/domain/usecases/login_usecase.dart';
import 'package:aqua_life/features/auth/domain/usecases/register_usecase.dart';
import 'package:aqua_life/features/auth/presentation/state/auth_state.dart';

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(
    loginUseCase: ref.watch(loginUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
  );
});

class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;

  AuthViewModel({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        super(AuthState.initial());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _loginUseCase(email, password);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message, isSuccess: false);
      },
      (success) {
        state = state.copyWith(isLoading: false, error: null, isSuccess: true);
      },
    );
  }

  Future<void> register(AuthEntity entity) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _registerUseCase(entity);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message, isSuccess: false);
      },
      (success) {
        state = state.copyWith(isLoading: false, error: null, isSuccess: true);
      },
    );
  }
}
