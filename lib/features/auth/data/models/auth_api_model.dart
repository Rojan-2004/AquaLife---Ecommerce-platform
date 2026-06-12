import 'package:aqua_life/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String username;
  final String? password;
  final String? profilePicture;
  final String? token;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.username,
    this.password,
    this.profilePicture,
    this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': fullName,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'username': username,
      'password': password,
      'profilePicture': profilePicture,
    };
  }

  factory AuthApiModel.fromJson(dynamic json) {
    final root = _requireMap(json, context: 'Auth API response');
    final dataValue = root['data'];
    final data = dataValue == null
        ? root
        : _requireMap(dataValue, context: 'Auth API response.data');

    return AuthApiModel(
      id: _asStringOrNull(data['_id'] ?? data['id'], name: 'id'),
      fullName: _asString(
        value: data['fullName'] ?? data['name'],
        name: 'fullName',
        defaultValue: 'Aqua User',
      ),
      email: _asString(value: data['email'], name: 'email', defaultValue: ''),
      phoneNumber: _asStringOrNull(data['phoneNumber'], name: 'phoneNumber'),
      username: _asString(
        value: data['username'],
        name: 'username',
        defaultValue: '',
      ),
      profilePicture: _asStringOrNull(
        data['profilePicture'],
        name: 'profilePicture',
      ),
      token: _asStringOrNull(root['token'] ?? data['token'], name: 'token'),
    );
  }

  static Map<String, dynamic> _requireMap(
    dynamic value, {
    required String context,
  }) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (key, innerValue) => MapEntry(key.toString(), innerValue),
      );
    }

    final actualType = value == null ? 'null' : value.runtimeType.toString();
    throw FormatException('$context must be a Map, but got $actualType.');
  }

  static String? _asStringOrNull(dynamic value, {required String name}) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();

    throw FormatException(
      'Expected "$name" to be a String, but got ${value.runtimeType}.',
    );
  }

  static String _asString({
    dynamic value,
    required String name,
    required String defaultValue,
  }) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();

    throw FormatException(
      'Expected "$name" to be a String, but got ${value.runtimeType}.',
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      username: username,
      password: password,
      profilePicture: profilePicture,
    );
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      password: entity.password,
      username: entity.username,
      profilePicture: entity.profilePicture,
    );
  }

  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
