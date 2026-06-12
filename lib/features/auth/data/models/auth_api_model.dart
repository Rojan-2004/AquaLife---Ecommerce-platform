import 'package:aqua_life/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String username;
  final String? password;
  final String? batchId;
  final String? profilePicture;
  final String? token;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.username,
    this.password,
    this.batchId,
    this.profilePicture,
    this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'username': username,
      'password': password,
      'batchId': batchId,
      'profilePicture': profilePicture,
    };
  }

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'] ?? json['id'],
      fullName: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      username: json['username'],
      batchId: json['batchId'],
      profilePicture: json['profilePicture'],
      token: json['token'],
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
      batchId: batchId,
    );
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      password: entity.password,
      username: entity.username,
      batchId: entity.batchId,
      profilePicture: entity.profilePicture,
    );
  }

  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}