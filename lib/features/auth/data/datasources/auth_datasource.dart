import 'package:aqua_life/features/auth/data/models/auth_hive_model.dart';

abstract class IAuthDataSource {
  Future<AuthHiveModel?> login(String email, String password);
  Future<bool> register(AuthHiveModel model);
  Future<bool> logout();
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> isEmailExists(String email);
}
