import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/core/error/failures.dart';
import 'package:aqua_life/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:aqua_life/features/auth/data/models/auth_hive_model.dart';
import 'package:aqua_life/features/auth/domain/entities/auth_entity.dart';
import 'package:aqua_life/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final localDataSource = ref.watch(authLocalDatasourceProvider);
  return AuthRepositoryImpl(localDataSource: localDataSource);
});

class AuthRepositoryImpl implements IAuthRepository {
  final AuthLocalDatasource _localDataSource;

  AuthRepositoryImpl({required AuthLocalDatasource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _localDataSource.getCurrentUser();
      if (user != null) {
        return Right(user.toEntity());
      } else {
        return const Left(LocalDatabaseFailure(message: "User not found"));
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    try {
      final user = await _localDataSource.login(email, password);
      if (user != null) {
        return Right(user.toEntity());
      } else {
        return const Left(LocalDatabaseFailure(message: "Invalid email or password"));
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final success = await _localDataSource.logout();
      return Right(success);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      final isEmailExists = await _localDataSource.isEmailExists(entity.email);
      if (isEmailExists) {
        return const Left(LocalDatabaseFailure(message: "Email already exists"));
      }

      final model = AuthHiveModel.fromEntity(entity);
      final success = await _localDataSource.register(model);
      if (success) {
        return const Right(true);
      } else {
        return const Left(LocalDatabaseFailure(message: "Failed to register user"));
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}

