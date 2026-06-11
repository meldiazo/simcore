import 'package:simcore_frontend/features/auth/domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.username,
    required super.tenantId,
    required super.roles,
    super.groupId,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: _readInt(json['id']),
      username: json['username']?.toString() ??
          json['email']?.toString() ??
          'usuario',
      tenantId: _readInt(json['tenantId'], fallback: 1),
      roles: _readRoles(json['roles']),
      groupId: json['groupId'] != null ? _readInt(json['groupId']) : null,
    );
  }
}

int _readInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

List<String> _readRoles(dynamic rawRoles) {
  if (rawRoles is! List) return const [];

  return rawRoles
      .map(_roleFromAny)
      .whereType<String>()
      .map((role) => role.trim().toUpperCase())
      .where((role) => role.isNotEmpty)
      .map((role) => role.startsWith('ROLE_') ? role.substring(5) : role)
      .toSet()
      .toList(growable: false);
}

String? _roleFromAny(dynamic value) {
  if (value is String) return value;

  if (value is Map<String, dynamic>) {
    return value['name']?.toString() ??
        value['role']?.toString() ??
        value['authority']?.toString() ??
        value['code']?.toString();
  }

  if (value is Map) {
    return value['name']?.toString() ??
        value['role']?.toString() ??
        value['authority']?.toString() ??
        value['code']?.toString();
  }

  return null;
}