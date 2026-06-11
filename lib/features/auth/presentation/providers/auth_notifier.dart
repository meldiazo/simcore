import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/core/storage/token_storage.dart';
import 'package:simcore_frontend/core/storage/token_storage_provider.dart';
import 'package:simcore_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:simcore_frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:simcore_frontend/features/auth/domain/entities/auth_user.dart';
import 'package:simcore_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:simcore_frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:simcore_frontend/features/auth/presentation/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simcore_frontend/core/config/app_config.dart';
import 'package:simcore_frontend/features/auth/data/datasources/auth_mock_datasource.dart';

final Provider<AuthRemoteDataSource> _authDataSourceProvider =
    Provider<AuthRemoteDataSource>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMockData) {
    return AuthMockDataSource(ref.watch(tokenStorageProvider));
  }
  return AuthRemoteDataSourceImpl(ref.watch(iamApiClientProvider));
});

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    dataSource: ref.watch(_authDataSourceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final Provider<LoginUseCase> _loginUseCaseProvider =
    Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(
    this._loginUseCase,
    this._repository,
    this._storage,
  ) : super(const AuthState()) {
    _init();
  }

  final LoginUseCase _loginUseCase;
  final AuthRepository _repository;
  final TokenStorage _storage;

  Future<void> _init() async {
    final hasSession = await _storage.hasTokens();

    if (!hasSession) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    final result = await _repository.getMe();

    result.fold(
      (_) => state = state.copyWith(status: AuthStatus.unauthenticated),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ),
    );
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    );

    final result = await _loginUseCase(
      LoginParams(
        username: username,
        password: password,
      ),
    );

    result.fold(
      (failure) => state = AuthState(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (data) {
        final AuthUser user = data.$2;

        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
        );
      },
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void forceUnauthenticated() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final StateNotifierProvider<AuthNotifier, AuthState> authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier(
    ref.watch(_loginUseCaseProvider),
    ref.watch(authRepositoryProvider),
    ref.watch(tokenStorageProvider),
  );

  ref.listen<int>(sessionExpiredSignalProvider, (previous, next) {
    notifier.forceUnauthenticated();
  });

  return notifier;
});
