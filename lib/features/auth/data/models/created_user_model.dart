import 'package:simcore_frontend/features/auth/domain/entities/created_user.dart';

class CreatedUserModel extends CreatedUser {
  const CreatedUserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.enabled,
    required super.tenantId,
  });

  factory CreatedUserModel.fromJson(Map<String, dynamic> json) {
    return CreatedUserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      enabled: json['enabled'] as bool? ?? true,
      tenantId: json['tenantId'] as int,
    );
  }
}
