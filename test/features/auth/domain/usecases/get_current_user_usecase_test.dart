import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aqua_life/core/error/failures.dart';
import 'package:aqua_life/features/auth/domain/entities/auth_entity.dart';
import 'package:aqua_life/features/auth/domain/repositories/auth_repository.dart';
import 'package:aqua_life/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late GetCurrentUserUsecase useCase;
  late MockAuthRepository repository;

  const testUser = AuthEntity(
    fullName: 'Test User',
    email: 'test@example.com',
    username: 'testuser',
  );

  setUp(() {
    repository = MockAuthRepository();
    useCase = GetCurrentUserUsecase(authRepository: repository);
  });

  group('GetCurrentUser Usecase Tests', () {
    test(
      'should return AuthEntity when user is logged in',
      () async {
        // Arrange
        when(
          () => repository.getCurrentUser(),
        ).thenAnswer((_) async => const Right(testUser));

        // Act
        final result = await useCase();

        // Assert
        expect(result, const Right(testUser));

        verify(
          () => repository.getCurrentUser(),
        ).called(1);

        verifyNoMoreInteractions(repository);
      },
    );
  });
}