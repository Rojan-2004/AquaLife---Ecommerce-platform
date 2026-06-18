import 'package:aqua_life/core/error/failures.dart';
import 'package:aqua_life/core/services/connectivity/network_info.dart';
import 'package:aqua_life/core/services/storage/token_service.dart';
import 'package:aqua_life/core/services/storage/user_session_service.dart';
import 'package:aqua_life/features/auth/data/datasources/auth_datasource.dart';
import 'package:aqua_life/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:aqua_life/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:aqua_life/features/auth/data/models/auth_api_model.dart';
import 'package:aqua_life/features/auth/data/models/auth_hive_model.dart';
import 'package:aqua_life/features/auth/domain/entities/auth_entity.dart';
import 'package:aqua_life/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.read(authLocalDatasourceProvider);
  final authRemoteDatasource = ref.read(authRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  final tokenService = ref.read(tokenServiceProvider);
  return AuthRepository(
    authDatasource: authDatasource,
    authRemoteDataSource: authRemoteDatasource,
    networkInfo: networkInfo,
    userSessionService: userSessionService,
    tokenService: tokenService,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource _authDataSource;
  final IAuthRemoteDataSource _authRemoteDataSource;
  final NetworkInfo _networkInfo;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRepository({
    required IAuthLocalDataSource authDatasource,
    required IAuthRemoteDataSource authRemoteDataSource,
    required NetworkInfo networkInfo,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _authDataSource = authDatasource,
       _authRemoteDataSource = authRemoteDataSource,
       _networkInfo = networkInfo,
       _userSessionService = userSessionService,
       _tokenService = tokenService;

  @override
  Future<Either<Failure, bool>> register(AuthEntity user) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = AuthApiModel.fromEntity(user);
        final result = await _authRemoteDataSource.register(apiModel);
        if (result != null) {
          if (result.token != null) {
            await _tokenService.saveToken(result.token!);
          }
          if (result.refreshToken != null) {
            await _tokenService.saveRefreshToken(result.refreshToken!);
          }
          await _userSessionService.saveUserSession(
            userId: result.id ?? '',
            email: result.email,
            username: result.username,
            fullName: result.fullName,
            phoneNumber: result.phoneNumber,
            profilePicture: result.profilePicture,
          );
          final authModel = AuthHiveModel(
            authId: result.id,
            fullName: result.fullName,
            email: result.email,
            phoneNumber: result.phoneNumber,
            username: result.username,
            password: user.password,
            profilePicture: result.profilePicture,
          );
          await _authDataSource.register(authModel);
        }
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: _extractErrorMessage(e.response?.data, 'Registration failed'),
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return const Left(ApiFailure(message: 'Registration failed. Please try again.'));
      }
    } else {
      try {
        final exists = await _authDataSource.isEmailExists(user.email);
        if (exists) {
          return const Left(
            LocalDatabaseFailure(message: "Email already registered"),
          );
        }

        final authModel = AuthHiveModel(
          fullName: user.fullName,
          email: user.email,
          phoneNumber: user.phoneNumber,
          username: user.username,
          password: user.password,
          profilePicture: user.profilePicture,
        );
        await _authDataSource.register(authModel);
        return const Right(true);
      } catch (e) {
        return const Left(LocalDatabaseFailure(message: 'Unable to register offline'));
      }
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.login(email, password);
        if (apiModel != null) {
          if (apiModel.token != null) {
            await _tokenService.saveToken(apiModel.token!);
          }
          if (apiModel.refreshToken != null) {
            await _tokenService.saveRefreshToken(apiModel.refreshToken!);
          }
          await _userSessionService.saveUserSession(
            userId: apiModel.id ?? '',
            email: apiModel.email,
            username: apiModel.username,
            fullName: apiModel.fullName,
            phoneNumber: apiModel.phoneNumber,
            profilePicture: apiModel.profilePicture,
          );
          final authModel = AuthHiveModel(
            authId: apiModel.id,
            fullName: apiModel.fullName,
            email: apiModel.email,
            phoneNumber: apiModel.phoneNumber,
            username: apiModel.username,
            password: password,
            profilePicture: apiModel.profilePicture,
          );
          await _authDataSource.register(authModel);

          final entity = apiModel.toEntity();
          return Right(entity);
        }
        return const Left(ApiFailure(message: "Invalid email or password"));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: _extractErrorMessage(e.response?.data, 'Login failed'),
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return const Left(ApiFailure(message: 'Login failed. Please try again.'));
      }
    } else {
      try {
        final model = await _authDataSource.login(email, password);
        if (model != null) {
          final entity = model.toEntity();
          return Right(entity);
        }
        return const Left(
          LocalDatabaseFailure(message: "Invalid email or password"),
        );
      } catch (e) {
        return const Left(LocalDatabaseFailure(message: 'Unable to login offline'));
      }
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final model = await _authDataSource.getCurrentUser();
      if (model != null) {
        final entity = model.toEntity();
        return Right(entity);
      }
      return const Left(LocalDatabaseFailure(message: "No user logged in"));
    } catch (e) {
      return const Left(LocalDatabaseFailure(message: 'Unable to get user profile'));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await _tokenService.clearToken();
      final result = await _authDataSource.logout();
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: "Failed to logout"));
    } catch (e) {
      return const Left(LocalDatabaseFailure(message: 'Logout failed'));
    }
  }
}

String _extractErrorMessage(dynamic data, String fallback) {
  if (data is Map) {
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;
  }
  return fallback;
}
