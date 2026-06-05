import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userSharedPrefsProvider = Provider<UserSharedPrefs>((ref) {
  return UserSharedPrefs();
});

class UserSharedPrefs {
  late SharedPreferences _sharedPreferences;

  // Set first time
  Future<Either<String, bool>> setFirstTime(bool isFirstTime) async {
    try {
      _sharedPreferences = await SharedPreferences.getInstance();
      await _sharedPreferences.setBool('isFirstTime', isFirstTime);
      return const Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // Get first time
  Future<Either<String, bool>> getFirstTime() async {
    try {
      _sharedPreferences = await SharedPreferences.getInstance();
      final isFirstTime = _sharedPreferences.getBool('isFirstTime') ?? true;
      return Right(isFirstTime);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // Set User token
  Future<Either<String, bool>> setUserToken(String token) async {
    try {
      _sharedPreferences = await SharedPreferences.getInstance();
      await _sharedPreferences.setString('token', token);
      return const Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // Get User token
  Future<Either<String, String?>> getUserToken() async {
    try {
      _sharedPreferences = await SharedPreferences.getInstance();
      final token = _sharedPreferences.getString('token');
      return Right(token);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
