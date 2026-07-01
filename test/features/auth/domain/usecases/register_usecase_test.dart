import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aqua_life/core/error/failures.dart';
import 'package:aqua_life/features/auth/domain/entities/auth_entity.dart';
import 'package:aqua_life/features/auth/domain/repositories/auth_repository.dart';
import 'package:aqua_life/features/auth/domain/usecases/register_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class FakeRegisterParams extends Fake implements RegisterParams {}

class FakeAuthEntity extends Fake implements AuthEntity {}

void main() {
  late RegisterUsecase useCase;
  late MockAuthRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeRegisterParams());
    registerFallbackValue(FakeAuthEntity());
  });

  setUp(() {
    repository = MockAuthRepository();
    useCase = RegisterUsecase(authRepository: repository);
  });

  group('Register Usecase Tests', () {
    test(
      'should return Right(true) when registration is successful',
      () async {
        // Arrange
        const registerParams = RegisterParams(
          fullName: 'Test User',
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
        );

        when(
          () => repository.register(any()),
        ).thenAnswer((_) async => const Right(true));

        // Act
        final result = await useCase(registerParams);

        // Assert
        expect(result, const Right(true));

        verify(
          () => repository.register(any()),
        ).called(1);

        verifyNoMoreInteractions(repository);
      },
    );
  });
}