import 'package:simcore_frontend/features/auth/domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.username,
    required super.tenantId,
    required super.roles,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      tenantId: json['tenantId'] as int,
      roles: List<String>.from(json['roles'] as List),
    );
  }
}
