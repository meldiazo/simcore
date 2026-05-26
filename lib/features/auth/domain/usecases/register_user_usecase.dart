import 'package:simcore_frontend/core/error/failure.dart';
import 'package:simcore_frontend/features/auth/domain/entities/created_user.dart';
import 'package:simcore_frontend/features/auth/domain/repositories/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class RegisterUserUseCase {
  const RegisterUserUseCase(this._repository);

  final UserRepository _repository;

  /// Crea el usuario y luego le asigna el rol en una sola operación.
  Future<Either<Failure, CreatedUser>> call(RegisterUserParams params) async {
    final createResult = await _repository.createUser(
      username: params.username,
      email: params.email,
      password: params.password,
      firstName: params.firstName,
      lastName: params.lastName,
      tenantId: params.tenantId,
    );

    return createResult.fold(
      (failure) => Left(failure),
      (user) async {
        final assignResult = await _repository.assignRole(
          userId: user.id,
          roleId: params.roleId,
        );
        return assignResult.fold(
          (failure) => Left(failure),
          (updatedUser) => Right(updatedUser),
        );
      },
    );
  }
}

class RegisterUserParams extends Equatable {
  const RegisterUserParams({
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.roleId,
    this.tenantId = 1,
  });

  final String username;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final int roleId;
  final int tenantId;

  @override
  List<Object?> get props =>
      [username, email, password, firstName, lastName, roleId, tenantId];
}
