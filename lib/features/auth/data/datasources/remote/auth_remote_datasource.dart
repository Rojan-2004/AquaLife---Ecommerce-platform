import 'package:aqua_life/core/api/api_client.dart';
import 'package:aqua_life/core/api/api_endpoints.dart';
import 'package:aqua_life/features/auth/data/models/auth_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class IAuthRemoteDataSource {
  Future<AuthApiModel?> login(String email, String password);
  Future<AuthApiModel?> register(AuthApiModel model);
  Future<AuthApiModel?> refreshToken(String? refreshToken);
}

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    try {
      debugPrint('LOGIN REQUEST: email=$email to ${ApiEndpoints.authLogin}');
      final response = await _apiClient.post(
        ApiEndpoints.authLogin,
        data: {'email': email, 'password': password},
      );
      debugPrint('LOGIN RESPONSE: status=${response.statusCode} data=${response.data}');
      if (response.statusCode == 200 && response.data != null) {
        final model = AuthApiModel.fromJson(response.data);
        debugPrint('LOGIN PARSED: id=${model.id} email=${model.email} token=${model.token != null}');
        return model;
      }
      return null;
    } on DioException catch (e) {
      debugPrint('LOGIN DIO ERROR: ${e.response?.data} ${e.message}');
      throw Exception(
        _messageFromResponseData(e.response?.data, 'Login failed'),
      );
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<AuthApiModel?> register(AuthApiModel model) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.authRegister,
        data: model.toJson(),
      );
      if (response.statusCode == 201 && response.data != null) {
        return AuthApiModel.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      throw Exception(
        _messageFromResponseData(e.response?.data, 'Registration failed'),
      );
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<AuthApiModel?> refreshToken(String? refreshToken) async {
    if (refreshToken == null) return null;
    try {
      final response = await _apiClient.post(
        ApiEndpoints.authRefreshToken,
        data: {'refreshToken': refreshToken},
      );
      if (response.statusCode == 200 && response.data != null) {
        return AuthApiModel.fromJson(response.data);
      }
      return null;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }
}

String _messageFromResponseData(dynamic data, String fallback) {
  if (data is Map) {
    final message = data['message'];
    if (message is String) return message;
  }

  if (data is String && data.trim().isNotEmpty) return data;

  return fallback;
}

final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthRemoteDatasource(apiClient: apiClient);
});
