import 'dart:io';

class ApiConstants {
  ApiConstants._();

  static String get _localIp {
    if (Platform.isAndroid) {
      return '192.168.100.101';
    }
    if (Platform.isIOS) {
      return '127.0.0.1';
    }
    return '192.168.100.101';
  }

  static final String baseUrl = 'http://$_localIp:3000';

  static String getFullImageUrl(String? imgPath) {
    if (imgPath == null || imgPath.isEmpty) return '';
    if (imgPath.startsWith('http')) return imgPath;
    var path = imgPath.startsWith('/') ? imgPath : '/$imgPath';
    if (!path.contains('/item_photos/') && !path.contains('default-product')) {
      path = '/item_photos$path';
    }
    return '$baseUrl$path';
  }
}
