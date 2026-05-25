import 'package:core_sim_ia/core/network/api_client.dart';
import 'package:core_sim_ia/features/auth/data/models/auth_tokens_model.dart';
import 'package:core_sim_ia/features/auth/data/models/auth_user_model.dart';
import 'package:dio/dio.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthTokensModel> login({
    required String username,
    required String password,
  });

  Future<AuthUserModel> getMe(String accessToken);

  Future<AuthTokensModel> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<AuthTokensModel> login({
    required String username,
    required String password,
  }) async {
    final result = await _client.post(
      '/api/v1/iam/auth/login',
      data: {'username': username, 'password': password},
    );

    return result.fold(
      (exception) => throw exception,
      (data) => AuthTokensModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<AuthUserModel> getMe(String accessToken) async {
    final result = await _client.get(
      '/api/v1/iam/auth/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    return result.fold(
      (exception) => throw exception,
      (data) => AuthUserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    final result = await _client.post(
      '/api/v1/iam/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    return result.fold(
      (exception) => throw exception,
      (data) => AuthTokensModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
