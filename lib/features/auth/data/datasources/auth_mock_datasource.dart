import 'package:simcore_frontend/core/storage/token_storage.dart';
import 'package:simcore_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:simcore_frontend/features/auth/data/models/auth_tokens_model.dart';
import 'package:simcore_frontend/features/auth/data/models/auth_user_model.dart';

class AuthMockDataSource implements AuthRemoteDataSource {
  const AuthMockDataSource(this._tokenStorage);

  final TokenStorage _tokenStorage;

  @override
  Future<AuthTokensModel> login({
    required String username,
    required String password,
  }) async {
    return AuthTokensModel(
      accessToken: 'mock-token-$username',
      refreshToken: 'mock-refresh-token-$username',
      tokenType: 'Bearer',
      expiresIn: 3600,
    );
  }

  @override
  Future<AuthUserModel> getMe() async {
    final token = await _tokenStorage.getAccessToken() ?? '';
    final username = token.startsWith('mock-token-')
        ? token.substring('mock-token-'.length)
        : 'estudiante';

    final roles = <String>[];
    if (username.toLowerCase() == 'admin') {
      roles.add('ADMIN');
    } else if (username.toLowerCase() == 'docente' || username.toLowerCase() == 'teacher') {
      roles.add('DOCENTE');
    } else {
      roles.add('ESTUDIANTE');
    }

    return AuthUserModel(
      id: 1,
      username: username,
      tenantId: 1,
      roles: roles,
      groupId: 1, // Default mock group
    );
  }

  @override
  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    final username = refreshToken.startsWith('mock-refresh-token-')
        ? refreshToken.substring('mock-refresh-token-'.length)
        : 'estudiante';

    return AuthTokensModel(
      accessToken: 'mock-token-$username',
      refreshToken: 'mock-refresh-token-$username',
      tokenType: 'Bearer',
      expiresIn: 3600,
    );
  }
}
