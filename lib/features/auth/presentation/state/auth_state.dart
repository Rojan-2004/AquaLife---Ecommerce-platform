import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const AuthState({
    required this.isLoading,
    this.error,
    required this.isSuccess,
  });

  factory AuthState.initial() {
    return const AuthState(
      isLoading: false,
      error: null,
      isSuccess: false,
    );
  }

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, isSuccess];
}
