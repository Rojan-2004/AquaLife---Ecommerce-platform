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
  final String? refreshToken;
  final String? role;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.username,
    this.password,
    this.profilePicture,
    this.token,
    this.refreshToken,
    this.role,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'name': fullName,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'username': username,
      'password': password,
    };
    if (profilePicture != null && profilePicture!.isNotEmpty) {
      json['profilePicture'] = profilePicture;
    }
    if (role != null && role!.isNotEmpty) {
      json['role'] = role;
    }
    return json;
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
      role: _asStringOrNull(data['role'], name: 'role'),
      token: _asStringOrNull(root['token'] ?? data['token'], name: 'token'),
      refreshToken: _asStringOrNull(
        root['refreshToken'] ?? data['refreshToken'],
        name: 'refreshToken',
      ),
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
      role: role,
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
      role: entity.role,
    );
  }

  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
