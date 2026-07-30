import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aqua_life/core/error/failures.dart';
import 'package:aqua_life/features/auth/domain/entities/auth_entity.dart';
import 'package:aqua_life/features/auth/domain/repositories/auth_repository.dart';
import 'package:aqua_life/features/auth/domain/usecases/login_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUsecase useCase;
  late MockAuthRepository repository;

  const correctEmail = 'test@example.com';
  const correctPassword = 'password123';

  const testUser = AuthEntity(
    fullName: 'Test User',
    email: correctEmail,
    username: 'testuser',
  );

  setUp(() {
    repository = MockAuthRepository();
    useCase = LoginUsecase(authRepository: repository);
  });

  group('Login Usecase Tests', () {
    test(
      'should return AuthEntity when correct email and password are provided',
      () async {
        // Arrange
        when(
          () => repository.login(any(), any()),
        ).thenAnswer((_) async => const Right(testUser));

        // Act
        final result = await useCase(
          const LoginParams(
            email: correctEmail,
            password: correctPassword,
          ),
        );

        // Assert
        expect(result, const Right(testUser));

        verify(
          () => repository.login(correctEmail, correctPassword),
        ).called(1);

        verifyNoMoreInteractions(repository);
      },
    );
  });
}