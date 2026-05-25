import 'package:core_sim_ia/core/config/app_config.dart';
import 'package:core_sim_ia/core/network/api_client.dart';
import 'package:core_sim_ia/core/storage/token_storage.dart';
import 'package:core_sim_ia/core/storage/token_storage_provider.dart';
import 'package:core_sim_ia/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:core_sim_ia/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:core_sim_ia/features/auth/domain/entities/auth_user.dart';
import 'package:core_sim_ia/features/auth/domain/repositories/auth_repository.dart';
import 'package:core_sim_ia/features/auth/domain/usecases/login_usecase.dart';
import 'package:core_sim_ia/features/auth/presentation/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Providers de infraestructura ──────────────────────────────────────────────

final Provider<ApiClient> _authApiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final storage = ref.watch(tokenStorageProvider);

  return ApiClient(
    baseUrl: config.iamUrl,
    tokenProvider: () => storage.getAccessToken(),
    onRefresh: () async {
      final refreshToken = await storage.getRefreshToken();
      if (refreshToken == null) return null;

      final tempClient = ApiClient(baseUrl: config.iamUrl);
      final dataSource = AuthRemoteDataSourceImpl(tempClient);
      final repo = AuthRepositoryImpl(dataSource: dataSource, tokenStorage: storage);
      final result = await repo.refreshToken(refreshToken);
      return result.fold((_) => null, (tokens) => tokens.accessToken);
    },
    onSessionExpired: () => ref.read(authNotifierProvider.notifier).logout(),
  );
});

final Provider<AuthRemoteDataSource> _authDataSourceProvider =
    Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(_authApiClientProvider));
});

final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    dataSource: ref.watch(_authDataSourceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final Provider<LoginUseCase> _loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

// ── Notifier principal ────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._loginUseCase, this._repository, this._storage)
      : super(const AuthState()) {
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
    final accessToken = await _storage.getAccessToken();
    if (accessToken == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    final result = await _repository.getMe(accessToken);
    result.fold(
      (_) => state = state.copyWith(status: AuthStatus.unauthenticated),
      (user) => state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _loginUseCase(
      LoginParams(username: username, password: password),
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
}

final StateNotifierProvider<AuthNotifier, AuthState> authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(_loginUseCaseProvider),
    ref.watch(authRepositoryProvider),
    ref.watch(tokenStorageProvider),
  );
});
