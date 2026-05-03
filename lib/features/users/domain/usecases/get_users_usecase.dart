import 'package:core_sim_ia/core/utils/typedefs.dart';
import 'package:core_sim_ia/features/users/domain/entities/user_entity.dart';
import 'package:core_sim_ia/features/users/domain/repositories/users_repository.dart';

class GetUsersUseCase {
  const GetUsersUseCase(this._repository);

  final UsersRepository _repository;

  FutureResult<List<UserEntity>> call() {
    return _repository.getUsers();
  }
}
