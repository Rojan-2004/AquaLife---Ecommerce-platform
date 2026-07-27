import 'dart:io';

class ApiEndpoints {
  ApiEndpoints._();

  static String get _localIp => '10.2.14.27';

  static final String baseUrl = Platform.isAndroid
      ? 'http://$_localIp:3000'
      : 'http://$_localIp:3000';

  static final String apiBaseUrl = '$baseUrl/api/v1';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String auth = '/api/v1/auth';
  static const String authRegister = '/api/v1/auth/register';
  static const String authLogin = '/api/v1/auth/login';
  static const String authMe = '/api/v1/auth/me';
  static const String authProfile = '/api/v1/auth/profile';
  static const String authLogout = '/api/v1/auth/logout';
  static const String authRefreshToken = '/api/v1/auth/refresh-token';
  static const String authUpdateProfile = '/api/v1/auth/update-profile';
  static const String authUploadProfilePicture =
      '/api/v1/auth/upload-profile-picture';
  static const String products = '/api/v1/products';
  static const String categories = '/api/v1/categories';
  static const String cart = '/api/v1/cart';
  static const String orders = '/api/v1/orders';
  static const String reviews = '/api/v1/reviews';
}
