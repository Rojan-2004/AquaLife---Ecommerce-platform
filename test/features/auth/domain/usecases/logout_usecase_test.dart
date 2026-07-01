import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aqua_life/core/error/failures.dart';
import 'package:aqua_life/features/auth/domain/repositories/auth_repository.dart';
import 'package:aqua_life/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LogoutUsecase useCase;
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
    useCase = LogoutUsecase(authRepository: repository);
  });

  group('Logout Usecase Tests', () {
    test(
      'should return Right(true) when logout is successful',
      () async {
        // Arrange
        when(
          () => repository.logout(),
        ).thenAnswer((_) async => const Right(true));

        // Act
        final result = await useCase();

        // Assert
        expect(result, const Right(true));

        verify(
          () => repository.logout(),
        ).called(1);

        verifyNoMoreInteractions(repository);
      },
    );
  });
}