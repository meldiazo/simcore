import 'package:core_sim_ia/core/error/failure.dart';
import 'package:core_sim_ia/features/auth/domain/entities/auth_tokens.dart';
import 'package:core_sim_ia/features/auth/domain/entities/auth_user.dart';
import 'package:dartz/dartz.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, AuthTokens>> login({
    required String username,
    required String password,
  });

  Future<Either<Failure, AuthUser>> getMe();

  Future<Either<Failure, AuthTokens>> refreshToken(String refreshToken);

  Future<void> logout();
}
