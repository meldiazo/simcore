import 'package:core_sim_ia/core/error/failure.dart';
import 'package:core_sim_ia/core/network/api_exception.dart';
import 'package:core_sim_ia/core/storage/token_storage.dart';
import 'package:core_sim_ia/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:core_sim_ia/features/auth/domain/entities/auth_tokens.dart';
import 'package:core_sim_ia/features/auth/domain/entities/auth_user.dart';
import 'package:core_sim_ia/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource dataSource,
    required TokenStorage tokenStorage,
  })  : _dataSource = dataSource,
        _tokenStorage = tokenStorage;

  final AuthRemoteDataSource _dataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<Either<Failure, AuthTokens>> login({
    required String username,
    required String password,
  }) async {
    try {
      final tokens = await _dataSource.login(username: username, password: password);
      await _tokenStorage.saveTokens(
        StoredTokens(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        ),
      );
      return Right(tokens);
    } on ApiException catch (e) {
      return Left(_mapApiException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
Future<Either<Failure, AuthUser>> getMe() async {
  try {
    final user = await _dataSource.getMe();
    return Right(user);
  } on ApiException catch (e) {
    return Left(_mapApiException(e));
  } catch (e) {
    return Left(UnknownFailure(e.toString()));
  }
}

  @override
  Future<Either<Failure, AuthTokens>> refreshToken(String refreshToken) async {
    try {
      final tokens = await _dataSource.refreshToken(refreshToken);
      await _tokenStorage.saveTokens(
        StoredTokens(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        ),
      );
      return Right(tokens);
    } on ApiException catch (e) {
      return Left(_mapApiException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clearTokens();
  }

  Failure _mapApiException(ApiException e) {
    return switch (e.type) {
      ErrorType.network => NetworkFailure(e.message),
      ErrorType.unauthorized => const ServerFailure('Credenciales inválidas'),
      ErrorType.forbidden => const ServerFailure('Usuario desactivado'),
      _ => ServerFailure(e.message),
    };
  }
}
