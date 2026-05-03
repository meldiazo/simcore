import 'package:core_sim_ia/core/error/failure.dart';
import 'package:core_sim_ia/features/users/domain/entities/user_entity.dart';
import 'package:core_sim_ia/features/users/presentation/providers/users_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'users_controller.g.dart';

@riverpod
class UsersController extends _$UsersController {
  @override
  Future<List<UserEntity>> build() {
    return _fetchUsers();
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchUsers);
  }

  Future<List<UserEntity>> _fetchUsers() async {
    final result = await ref.read(getUsersUseCaseProvider).call();

    return result.fold(
      onSuccess: (users) => users,
      onFailure: (failure) => throw failure,
    );
  }
}

String usersErrorMessage(Object error) {
  if (error is Failure) {
    return error.message;
  }

  return 'Unexpected error';
}
