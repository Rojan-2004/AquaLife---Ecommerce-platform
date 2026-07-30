import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:aqua_life/app/constants/api_constants.dart';

class ApiService {
  static Future<Map<String, String>> headers() async {
    final prefs = await SharedPreferences.getInstance();
    final cookie = prefs.getString('session_cookie') ?? '';
    final headersMap = {
      'Content-Type': 'application/json',
      'Cookie': cookie,
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
    final uri = Uri.parse('${ApiConstants.baseUrl}${_resolvePath(path)}');
    return _sendWithTimeout(http.get(uri, headers: await headers()));
  }

  static Future<http.Response> post(String path, dynamic body) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${_resolvePath(path)}');
    return _sendWithTimeout(http.post(uri, headers: await headers(), body: jsonEncode(body)));
  }

  static Future<http.Response> put(String path, dynamic body) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${_resolvePath(path)}');
    return _sendWithTimeout(http.put(uri, headers: await headers(), body: jsonEncode(body)));
  }

  static Future<http.Response> patch(String path, dynamic body) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${_resolvePath(path)}');
    return _sendWithTimeout(http.patch(uri, headers: await headers(), body: jsonEncode(body)));
  }

  static Future<http.Response> delete(String path, {dynamic body}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${_resolvePath(path)}');
    final request = http.Request('DELETE', uri);
    request.headers.addAll(await headers());
    if (body != null) {
      request.body = jsonEncode(body);
    }
    final streamedResponse = await request.send();
    return _sendWithTimeout(http.Response.fromStream(streamedResponse));
  }

  static Future<T> _sendWithTimeout<T>(Future<T> request) async {
    try {
      return await request.timeout(const Duration(seconds: 15));
    } on http.ClientException catch (e) {
      throw Exception(_describeError(e, 'Network request failed'));
    } on TimeoutException catch (_) {
      throw Exception('Request timed out. The server may be slow or unreachable.');
    } on Exception catch (e) {
      throw Exception(_describeError(e, 'Network error'));
    }
  }

  static String _describeError(Object e, String fallback) {
    final message = e.toString().trim();
    if (message.isEmpty) return fallback;

    if (message.contains('SocketException') || message.contains('Connection timed out') || message.contains('Connection refused')) {
      return 'Cannot reach server at ${ApiConstants.baseUrl}. Verify the backend is running and accessible from the emulator.';
    }
    if (message.contains('HandshakeException') || message.contains('TLS')) {
      return 'SSL handshake failed. Check that your backend URL uses HTTP for local development.';
    }
    if (message.contains('timeout')) {
      return 'Request timed out. The server may be slow or unreachable.';
    }

    final cleaned = message.replaceAll('Exception: ', '').trim();
    if (cleaned != message && cleaned.isNotEmpty) return cleaned;

    return fallback;
  }
}
