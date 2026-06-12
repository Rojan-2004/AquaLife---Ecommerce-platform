import 'package:equatable/equatable.dart';
import 'package:aqua_life/features/auth/domain/entities/auth_entity.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final AuthEntity? user;

  const AuthState({
    required this.isLoading,
    this.error,
    required this.isSuccess,
    this.user,
  });

  factory AuthState.initial() {
    return const AuthState(
      isLoading: false,
      error: null,
      isSuccess: false,
      user: null,
    );
  }

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    AuthEntity? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, isSuccess, user];
}
