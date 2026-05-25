import 'package:core_sim_ia/core/error/failure.dart';
import 'package:core_sim_ia/core/network/api_exception.dart';
import 'package:core_sim_ia/features/auth/data/datasources/user_remote_datasource.dart';
import 'package:core_sim_ia/features/auth/domain/entities/created_user.dart';
import 'package:core_sim_ia/features/auth/domain/repositories/user_repository.dart';
import 'package:dartz/dartz.dart';

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl(this._dataSource);

  final UserRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, CreatedUser>> createUser({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int tenantId,
  }) async {
    try {
      final user = await _dataSource.createUser(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        tenantId: tenantId,
      );
      return Right(user);
    } on ApiException catch (e) {
      return Left(_mapException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CreatedUser>> assignRole({
    required int userId,
    required int roleId,
  }) async {
    try {
      final user = await _dataSource.assignRole(userId: userId, roleId: roleId);
      return Right(user);
    } on ApiException catch (e) {
      return Left(_mapException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Failure _mapException(ApiException e) {
    return switch (e.type) {
      ErrorType.network => NetworkFailure(e.message),
      ErrorType.unauthorized => const ServerFailure('Tu sesión expiró. Vuelve a iniciar sesión.'),
      ErrorType.forbidden => const ServerFailure('No tienes permisos para crear usuarios.'),
      _ => ServerFailure(e.message),
    };
  }
}
