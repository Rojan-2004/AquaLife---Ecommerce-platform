import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/features/auth/domain/entities/auth_entity.dart';
import 'package:aqua_life/features/auth/domain/usecases/login_usecase.dart';
import 'package:aqua_life/features/auth/domain/usecases/register_usecase.dart';
import 'package:aqua_life/features/auth/presentation/state/auth_state.dart';

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(
    loginUseCase: ref.watch(loginUsecaseProvider),
    registerUseCase: ref.watch(registerUsecaseProvider),
  );
});

class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUsecase _loginUseCase;
  final RegisterUsecase _registerUseCase;

  AuthViewModel({
    required LoginUsecase loginUseCase,
    required RegisterUsecase registerUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        super(AuthState.initial());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _loginUseCase(LoginParams(email: email, password: password));

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message, isSuccess: false);
      },
      (success) {
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
      batchId: entity.batchId,
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
}
