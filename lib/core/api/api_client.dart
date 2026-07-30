import 'package:aqua_life/core/api/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectionTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor(_dio));

    // Auto retry on network failures
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
        retryEvaluator: (error, attempt) {
          // Retry on connection errors and timeouts, not on 4xx/5xx
          return error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError;
        },
      ),
    );

    // Only add logger in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }
  }

  Dio get dio => _dio;

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Multipart request for file uploads
  Future<Response> uploadFile(
    String path, {
    required FormData formData,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    return _dio.post(
      path,
      data: formData,
      options: options,
      onSendProgress: onSendProgress,
    );
  }
}

// Auth Interceptor to add JWT token to requests
class _AuthInterceptor extends Interceptor {
  final Dio dio;
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  _AuthInterceptor(this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    final publicEndpoints = [
      ApiEndpoints.authLogin,
      ApiEndpoints.authRegister,
      ApiEndpoints.authRefreshToken,
    ];

    final isPublicGet =
        options.method == 'GET' &&
        publicEndpoints.any((endpoint) => options.path.startsWith(endpoint));

    final isAuthEndpoint =
        options.path == ApiEndpoints.authLogin ||
        options.path == ApiEndpoints.authRegister ||
        options.path == ApiEndpoints.authRefreshToken;

    if (!isPublicGet && !isAuthEndpoint) {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken != null) {
        try {
          final refreshResponse = await dio.post(
            ApiEndpoints.authRefreshToken,
            data: {'refreshToken': refreshToken},
          );
          if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
            final newToken = refreshResponse.data['token'] as String?;
            final newRefreshToken = refreshResponse.data['refreshToken'] as String?;
            if (newToken != null) {
              await _storage.write(key: _tokenKey, value: newToken);
              if (newRefreshToken != null) {
                await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
              }
              final RequestOptions request = err.requestOptions;
              request.headers['Authorization'] = 'Bearer $newToken';
              final retryResponse = await dio.fetch(request);
              return handler.resolve(retryResponse);
            }
          }
        } catch (_) {
          // Refresh failed, clear tokens
        }
      }
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
      return handler.next(err);
    }

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          type: err.type,
          error: 'Request to ${err.requestOptions.uri} timed out. Verify the backend is running and reachable.',
        ),
      );
    }

    if (err.type == DioExceptionType.connectionError) {
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          type: err.type,
          error: 'Cannot reach ${err.requestOptions.uri}. Check that the backend is running and accessible from the emulator.',
        ),
      );
    }

    handler.next(err);
  }
}
