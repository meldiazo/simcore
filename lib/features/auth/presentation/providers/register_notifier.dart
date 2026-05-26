import 'package:simcore_frontend/features/auth/data/datasources/user_remote_datasource.dart';
import 'package:simcore_frontend/features/auth/data/repositories/user_repository_impl.dart';
import 'package:simcore_frontend/features/auth/domain/repositories/user_repository.dart';
import 'package:simcore_frontend/features/auth/domain/usecases/register_user_usecase.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/auth/presentation/providers/register_state.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Infraestructura ───────────────────────────────────────────────────────────

final Provider<UserRepository> userRepositoryProvider =
    Provider<UserRepository>((ref) {
  final client = ref.watch(iamApiClientProvider);

  return UserRepositoryImpl(
    UserRemoteDataSourceImpl(client),
  );
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

final StateNotifierProvider<RegisterNotifier, RegisterState>
    registerNotifierProvider =
    StateNotifierProvider<RegisterNotifier, RegisterState>((ref) {
  return RegisterNotifier(ref.watch(_registerUseCaseProvider));
});
