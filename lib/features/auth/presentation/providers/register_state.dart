import 'package:simcore_frontend/features/auth/domain/entities/created_user.dart';
import 'package:equatable/equatable.dart';

enum RegisterStatus { idle, loading, success, error }

class RegisterState extends Equatable {
  const RegisterState({
    this.status = RegisterStatus.idle,
    this.createdUser,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  final RegisterStatus status;
  final CreatedUser? createdUser;
  final String? errorMessage;

  /// Mapa de field → mensaje de error. Ej: {'username': 'Ya existe'}
  final Map<String, String> fieldErrors;

  bool get isLoading => status == RegisterStatus.loading;
  bool get isSuccess => status == RegisterStatus.success;

  RegisterState copyWith({
    RegisterStatus? status,
    CreatedUser? createdUser,
    String? errorMessage,
    Map<String, String>? fieldErrors,
  }) {
    return RegisterState(
      status: status ?? this.status,
      createdUser: createdUser ?? this.createdUser,
      errorMessage: errorMessage ?? this.errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  @override
  List<Object?> get props => [status, createdUser, errorMessage, fieldErrors];
}
