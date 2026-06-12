import 'dart:io';

class ApiEndpoints {
  ApiEndpoints._();

  static final String baseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:3000/api/v1'
      : 'http://127.0.0.1:3000/api/v1';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String auth = '/auth';
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';
  static const String authLogout = '/auth/logout';
}
