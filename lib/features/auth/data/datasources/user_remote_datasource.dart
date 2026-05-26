import 'package:core_sim_ia/core/network/api_client.dart';
import 'package:core_sim_ia/features/auth/data/models/created_user_model.dart';

abstract interface class UserRemoteDataSource {
  Future<CreatedUserModel> createUser({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int tenantId,
  });

  Future<CreatedUserModel> assignRole({
    required int userId,
    required int roleId,
  });
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  const UserRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<CreatedUserModel> createUser({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int tenantId,
  }) async {
    final result = await _client.post(
      '/api/v1/iam/users',
      data: {
        'username': username,
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'tenantId': tenantId,
      },
    );

    return result.fold(
      (exception) => throw exception,
      (data) => CreatedUserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<CreatedUserModel> assignRole({
    required int userId,
    required int roleId,
  }) async {
    final result = await _client.put(
      '/api/v1/iam/users/$userId/roles',
      data: {'roleIds': [roleId]},
    );

    return result.fold(
      (exception) => throw exception,
      (data) => CreatedUserModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
