import 'package:core_sim_ia/core/error/exceptions.dart';
import 'package:core_sim_ia/features/users/data/models/user_model.dart';

abstract interface class UsersRemoteDataSource {
  Future<List<UserModel>> getUsers();
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  const UsersRemoteDataSourceImpl({this.shouldFail = false});

  final bool shouldFail;

  @override
  Future<List<UserModel>> getUsers() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (shouldFail) {
      throw const ServerException('Failed to fetch users from remote source');
    }

    return const [
      UserModel(id: 1, name: 'Ada Lovelace', email: 'ada@coresim.dev'),
      UserModel(id: 2, name: 'Alan Turing', email: 'alan@coresim.dev'),
      UserModel(id: 3, name: 'Grace Hopper', email: 'grace@coresim.dev'),
      UserModel(
        id: 4,
        name: 'Katherine Johnson',
        email: 'katherine@coresim.dev',
      ),
    ];
  }
}
