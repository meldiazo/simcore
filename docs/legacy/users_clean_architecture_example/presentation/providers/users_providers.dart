import 'package:core_sim_ia/core/network/network_info.dart';
import 'package:core_sim_ia/features/users/data/datasources/users_remote_datasource.dart';
import 'package:core_sim_ia/features/users/data/repositories/users_repository_impl.dart';
import 'package:core_sim_ia/features/users/domain/repositories/users_repository.dart';
import 'package:core_sim_ia/features/users/domain/usecases/get_users_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'users_providers.g.dart';

@riverpod
bool simulateUsersError(Ref ref) {
  return false;
}

@riverpod
NetworkInfo networkInfo(Ref ref) {
  return const AlwaysConnectedNetworkInfo();
}

@riverpod
UsersRemoteDataSource usersRemoteDataSource(Ref ref) {
  final shouldFail = ref.watch(simulateUsersErrorProvider);
  return UsersRemoteDataSourceImpl(shouldFail: shouldFail);
}

@riverpod
UsersRepository usersRepository(Ref ref) {
  return UsersRepositoryImpl(
    remoteDataSource: ref.watch(usersRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
}

@riverpod
GetUsersUseCase getUsersUseCase(Ref ref) {
  return GetUsersUseCase(ref.watch(usersRepositoryProvider));
}
