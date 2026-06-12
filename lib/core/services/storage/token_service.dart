import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// provider
final tokenServiceProvider = Provider<TokenService>((ref) {
  return TokenService();
});

class TokenService {
  final FlutterSecureStorage _storage;
  static const String _tokenKey = 'auth_token';

  TokenService({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  // save token : secure storage
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // get token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // remove_token
  Future<void> removeToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }
}