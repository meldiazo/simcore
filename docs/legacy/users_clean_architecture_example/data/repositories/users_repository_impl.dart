import 'package:core_sim_ia/core/error/exceptions.dart';
import 'package:core_sim_ia/core/error/failure.dart';
import 'package:core_sim_ia/core/error/result.dart';
import 'package:core_sim_ia/core/network/network_info.dart';
import 'package:core_sim_ia/core/utils/typedefs.dart';
import 'package:core_sim_ia/features/users/data/datasources/users_remote_datasource.dart';
import 'package:core_sim_ia/features/users/domain/entities/user_entity.dart';
import 'package:core_sim_ia/features/users/domain/repositories/users_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  const UsersRepositoryImpl({
    required UsersRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  final UsersRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  FutureResult<List<UserEntity>> getUsers() async {
    if (!await _networkInfo.isConnected) {
      return const FailureResult<List<UserEntity>>(NetworkFailure());
    }

    try {
      final models = await _remoteDataSource.getUsers();
      final entities =
          models.map((model) => model.toEntity()).toList(growable: false);

      return Success<List<UserEntity>>(entities);
    } on ServerException catch (exception) {
      return FailureResult<List<UserEntity>>(ServerFailure(exception.message));
    } catch (_) {
      return const FailureResult<List<UserEntity>>(UnknownFailure());
    }
  }
}
