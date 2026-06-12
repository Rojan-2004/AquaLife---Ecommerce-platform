import 'package:aqua_life/core/api/api_client.dart';
import 'package:aqua_life/core/api/api_endpoints.dart';
import 'package:aqua_life/features/auth/data/models/auth_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class IAuthRemoteDataSource {
  Future<AuthApiModel?> login(String email, String password);
  Future<AuthApiModel?> register(AuthApiModel model);
}

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.authLogin,
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200 && response.data != null) {
        return AuthApiModel.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      throw Exception(
        _messageFromResponseData(e.response?.data, 'Login failed'),
      );
    } catch (e) {
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
