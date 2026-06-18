import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// provider
final tokenServiceProvider = Provider<TokenService>((ref) {
  return TokenService();
});

class TokenService {
  final FlutterSecureStorage _storage;
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  TokenService({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  // Save access token : secure storage
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Save refresh token : secure storage
  Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  // Get access token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // Remove access token
  Future<void> removeToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Remove refresh token
  Future<void> removeRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  // Clear both tokens
  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<void> clearToken() async {
    await clearTokens();
  }
}