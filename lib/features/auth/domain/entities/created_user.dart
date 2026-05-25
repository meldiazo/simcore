import 'package:equatable/equatable.dart';

class CreatedUser extends Equatable {
  const CreatedUser({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.enabled,
    required this.tenantId,
  });

  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool enabled;
  final int tenantId;

  @override
  List<Object?> get props => [id, username, email, firstName, lastName, enabled, tenantId];
}
