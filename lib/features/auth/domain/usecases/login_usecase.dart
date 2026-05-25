import 'package:core_sim_ia/core/error/failure.dart';
import 'package:core_sim_ia/features/auth/domain/entities/auth_tokens.dart';
import 'package:core_sim_ia/features/auth/domain/entities/auth_user.dart';
import 'package:core_sim_ia/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, (AuthTokens, AuthUser)>> call(LoginParams params) async {
    final tokensResult = await _repository.login(
      username: params.username,
      password: params.password,
    );

    return tokensResult.fold(
      (failure) => Left(failure),
      (tokens) async {
        final userResult = await _repository.getMe(tokens.accessToken);
        return userResult.fold(
          (failure) => Left(failure),
          (user) => Right((tokens, user)),
        );
      },
    );
  }
}

class LoginParams extends Equatable {
  const LoginParams({required this.username, required this.password});

  final String username;
  final String password;

  @override
  List<Object?> get props => [username, password];
}
