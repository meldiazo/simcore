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

  List<String> get normalizedRoles {
    return roles
        .map(_normalizeRole)
        .where((role) => role.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  bool hasRole(String role) {
    return normalizedRoles.contains(_normalizeRole(role));
  }

  bool get isAdmin => hasRole('ADMIN');
  bool get isDocente => hasRole('DOCENTE');
  bool get isEstudiante => hasRole('ESTUDIANTE');

  /// Solo ADMIN debe ver gestión general de usuarios.
  /// Si después quieres que DOCENTE cree estudiantes, lo hacemos como flujo aparte:
  /// "Crear estudiante / matricular estudiante", no como gestión global de usuarios.
  bool get canManageUsers => isAdmin;

  bool get canManageAcademicSetup => isAdmin || isDocente;
  bool get canReviewSimulation => isAdmin || isDocente;

  @override
  List<Object?> get props => [id, username, tenantId, roles];
}

String _normalizeRole(String role) {
  var value = role.trim().toUpperCase();

  if (value.startsWith('ROLE_')) {
    value = value.substring(5);
  }

  return value;
}