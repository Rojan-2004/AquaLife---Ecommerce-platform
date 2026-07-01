import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aqua_life/core/error/failures.dart';
import 'package:aqua_life/core/services/connectivity/network_info.dart';
import 'package:aqua_life/core/services/storage/token_service.dart';
import 'package:aqua_life/core/services/storage/user_session_service.dart';
import 'package:aqua_life/features/auth/data/datasources/auth_datasource.dart';
import 'package:aqua_life/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:aqua_life/features/auth/data/models/auth_hive_model.dart';
import 'package:aqua_life/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqua_life/features/auth/domain/entities/auth_entity.dart';

class MockAuthLocalDataSource extends Mock implements IAuthLocalDataSource {}

class MockAuthRemoteDataSource extends Mock implements IAuthRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockUserSessionService extends Mock implements UserSessionService {}

class MockTokenService extends Mock implements TokenService {}

void main() {
  late AuthRepository repository;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late MockUserSessionService mockUserSessionService;
  late MockTokenService mockTokenService;

  const testUser = AuthEntity(
    fullName: 'Test User',
    email: 'test@example.com',
    username: 'testuser',
  );

  setUp(() {
    mockLocalDataSource = MockAuthLocalDataSource();
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    mockUserSessionService = MockUserSessionService();
    mockTokenService = MockTokenService();

    repository = AuthRepository(
      authDatasource: mockLocalDataSource,
      authRemoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
      userSessionService: mockUserSessionService,
      tokenService: mockTokenService,
    );
  });

  group('Auth Repository Tests', () {
    test(
      'should return AuthEntity when getCurrentUser succeeds',
      () async {
        final hiveModel = AuthHiveModel(
          authId: '1',
          fullName: 'Test User',
          email: 'test@example.com',
          username: 'testuser',
        );

        when(() => mockLocalDataSource.getCurrentUser())
            .thenAnswer((_) async => hiveModel);

        final result = await repository.getCurrentUser();

        expect(result, Right(hiveModel.toEntity()));
        verify(() => mockLocalDataSource.getCurrentUser()).called(1);
      },
    );
  });
}
