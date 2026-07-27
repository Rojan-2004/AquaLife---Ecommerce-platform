import 'dart:io';

class ApiConstants {
  ApiConstants._();

  static String get _localIp => '10.2.14.27';

  static final String baseUrl = Platform.isAndroid
      ? 'http://$_localIp:3000'
      : 'http://$_localIp:3000';

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
