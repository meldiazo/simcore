import 'package:core_sim_ia/core/config/app_config.dart';
import 'package:core_sim_ia/core/network/api_client.dart';
import 'package:core_sim_ia/features/auth/data/datasources/user_remote_datasource.dart';
import 'package:core_sim_ia/features/auth/data/repositories/user_repository_impl.dart';
import 'package:core_sim_ia/features/auth/domain/repositories/user_repository.dart';
import 'package:core_sim_ia/features/auth/domain/usecases/register_user_usecase.dart';
import 'package:core_sim_ia/features/auth/presentation/providers/auth_notifier.dart';
import 'package:core_sim_ia/features/auth/presentation/providers/register_state.dart';
import 'package:core_sim_ia/core/storage/token_storage_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Infraestructura ───────────────────────────────────────────────────────────

final Provider<UserRepository> userRepositoryProvider = Provider<UserRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  final storage = ref.watch(tokenStorageProvider);

  final client = ApiClient(
    baseUrl: config.iamUrl,
    tokenProvider: () => storage.getAccessToken(),
    onSessionExpired: () => ref.read(authNotifierProvider.notifier).logout(),
  );

  return UserRepositoryImpl(UserRemoteDataSourceImpl(client));
});

final Provider<RegisterUserUseCase> _registerUseCaseProvider =
    Provider<RegisterUserUseCase>((ref) {
  return RegisterUserUseCase(ref.watch(userRepositoryProvider));
});

// ── Notifier ──────────────────────────────────────────────────────────────────

class RegisterNotifier extends StateNotifier<RegisterState> {
  RegisterNotifier(this._useCase) : super(const RegisterState());

  final RegisterUserUseCase _useCase;

  Future<void> register(RegisterUserParams params) async {
    state = const RegisterState(status: RegisterStatus.loading);

    final result = await _useCase(params);

    result.fold(
      (failure) => state = RegisterState(
        status: RegisterStatus.error,
        errorMessage: failure.message,
      ),
      (user) => state = RegisterState(
        status: RegisterStatus.success,
        createdUser: user,
      ),
    );
  }

  /// Parsea fieldErrors del backend y los expone por campo.
  void setFieldErrors(List<Map<String, dynamic>> fieldErrors) {
    final map = <String, String>{
      for (final e in fieldErrors)
        (e['field'] as String): (e['message'] as String),
    };
    state = RegisterState(
      status: RegisterStatus.error,
      fieldErrors: map,
    );
  }

  void reset() => state = const RegisterState();
}

final StateNotifierProvider<RegisterNotifier, RegisterState> registerNotifierProvider =
    StateNotifierProvider<RegisterNotifier, RegisterState>((ref) {
  return RegisterNotifier(ref.watch(_registerUseCaseProvider));
});
