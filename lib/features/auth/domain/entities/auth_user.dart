import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.username,
    required this.tenantId,
    required this.roles,
  });

  final int id;
  final String username;
  final int tenantId;
  final List<String> roles;

  bool get isAdmin => roles.contains('ADMIN');
  bool get isDocente => roles.contains('DOCENTE');
  bool get isEstudiante => roles.contains('ESTUDIANTE');
  bool get canManageUsers => isAdmin || isDocente;

  @override
  List<Object?> get props => [id, username, tenantId, roles];
}
