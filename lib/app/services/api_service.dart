import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:aqua_life/app/constants/api_constants.dart';

class ApiService {
  static Future<Map<String, String>> headers() async {
    final prefs  = await SharedPreferences.getInstance();
    final cookie = prefs.getString('session_cookie') ?? '';
    final headersMap = {
      'Content-Type': 'application/json',
      'Cookie':        cookie,
    };
    if (cookie.startsWith('token=')) {
      final token = cookie.replaceAll('token=', '');
      headersMap['Authorization'] = 'Bearer $token';
    }
    return headersMap;
  }

  static String _resolvePath(String path) {
    if (path.startsWith('/api/') && !path.startsWith('/api/v1/')) {
      return path.replaceFirst('/api/', '/api/v1/');
    }
    return path;
  }

  static Future<http.Response> get(String path) async {
    return http.get(
      Uri.parse('${ApiConstants.baseUrl}${_resolvePath(path)}'),
      headers: await headers(),
    );
  }

  static Future<http.Response> post(String path, dynamic body) async {
    return http.post(
      Uri.parse('${ApiConstants.baseUrl}${_resolvePath(path)}'),
      headers: await headers(),
      body:    jsonEncode(body),
    );
  }

  static Future<http.Response> patch(String path, dynamic body) async {
    return http.patch(
      Uri.parse('${ApiConstants.baseUrl}${_resolvePath(path)}'),
      headers: await headers(),
      body:    jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String path) async {
    return http.delete(
      Uri.parse('${ApiConstants.baseUrl}${_resolvePath(path)}'),
      headers: await headers(),
    );
  }
}
