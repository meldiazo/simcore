import 'package:core_sim_ia/core/utils/typedefs.dart';
import 'package:core_sim_ia/features/users/domain/entities/user_entity.dart';

abstract interface class UsersRepository {
  FutureResult<List<UserEntity>> getUsers();
}
