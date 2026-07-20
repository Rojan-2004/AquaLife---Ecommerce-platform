import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aqua_life/core/error/failures.dart';
import 'package:aqua_life/features/auth/domain/entities/auth_entity.dart';
import 'package:aqua_life/features/auth/domain/usecases/login_usecase.dart';
import 'package:aqua_life/features/auth/domain/usecases/logout_usecase.dart';
import 'package:aqua_life/features/auth/domain/usecases/register_usecase.dart';
import 'package:aqua_life/features/auth/presentation/state/auth_state.dart';
import 'package:aqua_life/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class FakeLoginParams extends Fake implements LoginParams {}

class FakeRegisterParams extends Fake implements RegisterParams {}

void main() {
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(FakeLoginParams());
    registerFallbackValue(FakeRegisterParams());
  });

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
    mockLogoutUsecase = MockLogoutUsecase();

    SharedPreferences.setMockInitialValues({});

    container = ProviderContainer(
      overrides: [
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state is correct', () {
    final state = container.read(authViewModelProvider);

    expect(state.isLoading, false);
    expect(state.error, isNull);
    expect(state.isSuccess, false);
    expect(state.user, isNull);
  });

  test('should emit loading then success state when login succeeds', () async {
    const testUser = AuthEntity(
      fullName: 'Test User',
      email: 'test@example.com',
      username: 'testuser',
    );

    when(() => mockLoginUsecase(any())).thenAnswer(
      (_) async => const Right(testUser),
    );

    await container
        .read(authViewModelProvider.notifier)
        .login('test@example.com', 'password123');

    final state = container.read(authViewModelProvider);

    expect(state.isSuccess, true);
    expect(state.user, testUser);
    expect(state.isLoading, false);
    expect(state.error, isNull);

    verify(() => mockLoginUsecase(any())).called(1);
  });

  test('should emit error state when login fails', () async {
    const failure = ApiFailure(
      message: 'Invalid credentials',
    );

    when(() => mockLoginUsecase(any())).thenAnswer(
      (_) async => const Left(failure),
    );

    await container
        .read(authViewModelProvider.notifier)
        .login('test@example.com', 'wrongpassword');

    final state = container.read(authViewModelProvider);

    expect(state.isSuccess, false);
    expect(state.isLoading, false);
    expect(state.error, 'Invalid credentials');
    expect(state.user, isNull);

    verify(() => mockLoginUsecase(any())).called(1);
  });

  test('should emit loading then success state when register succeeds', () async {
    when(() => mockRegisterUsecase(any())).thenAnswer(
      (_) async => const Right(true),
    );

    await container
        .read(authViewModelProvider.notifier)
        .register(
          const AuthEntity(
            fullName: 'Test User',
            email: 'test@example.com',
            username: 'testuser',
            password: 'password123',
          ),
        );

    final state = container.read(authViewModelProvider);

    expect(state.isSuccess, true);
    expect(state.isLoading, false);
    expect(state.error, isNull);

    verify(() => mockRegisterUsecase(any())).called(1);
  });

  test('should emit error state when register fails', () async {
    const failure = ApiFailure(
      message: 'Email already exists',
    );

    when(() => mockRegisterUsecase(any())).thenAnswer(
      (_) async => const Left(failure),
    );

    await container
        .read(authViewModelProvider.notifier)
        .register(
          const AuthEntity(
            fullName: 'Test User',
            email: 'test@example.com',
            username: 'testuser',
            password: 'password123',
          ),
        );

    final state = container.read(authViewModelProvider);

    expect(state.isSuccess, false);
    expect(state.isLoading, false);
    expect(state.error, 'Email already exists');

    verify(() => mockRegisterUsecase(any())).called(1);
  });

  test('resetState should reset to initial state', () {
    container.read(authViewModelProvider.notifier).resetState();

    final state = container.read(authViewModelProvider);

    expect(state.isLoading, false);
    expect(state.error, isNull);
    expect(state.isSuccess, false);
    expect(state.user, isNull);
  });
}