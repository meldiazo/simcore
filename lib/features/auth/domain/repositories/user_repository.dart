import 'package:simcore_frontend/core/error/failure.dart';
import 'package:simcore_frontend/features/auth/domain/entities/created_user.dart';
import 'package:dartz/dartz.dart';

abstract interface class UserRepository {
  Future<Either<Failure, CreatedUser>> createUser({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int tenantId,
  });

  Future<Either<Failure, CreatedUser>> assignRole({
    required int userId,
    required int roleId,
  });
}
