import 'package:dartz/dartz.dart';
import 'package:aqua_life/core/error/failures.dart';
import 'package:aqua_life/features/auth/domain/entities/auth_entity.dart';

abstract class IAuthRepository {
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, bool>> register(AuthEntity entity);
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, AuthEntity>> getCurrentUser();
}

