enum ErrorType {
  unauthorized, // 401
  forbidden,    // 403
  notFound,     // 404
  serverError,  // 500
  network,
  unknown,
}

class ApiException implements Exception {
  final ErrorType type;
  final String message;
  final int? statusCode;

  ApiException({
    required this.type,
    required this.message,
    this.statusCode,
  });

  /// Mapea los códigos de estado HTTP a un ErrorType específico
  factory ApiException.fromStatusCode(int? statusCode, [String? message]) {
    switch (statusCode) {
      case 401:
        return ApiException(
          type: ErrorType.unauthorized,
          message: message ?? 'No autorizado (Token expirado o inválido)',
          statusCode: statusCode,
        );
      case 403:
        return ApiException(
          type: ErrorType.forbidden,
          message: message ?? 'Acceso denegado a este recurso',
          statusCode: statusCode,
        );
      case 404:
        return ApiException(
          type: ErrorType.notFound,
          message: message ?? 'Recurso no encontrado',
          statusCode: statusCode,
        );
      case 500:
        return ApiException(
          type: ErrorType.serverError,
          message: message ?? 'Error interno del servidor',
          statusCode: statusCode,
        );
      default:
        return ApiException(
          type: ErrorType.unknown,
          message: message ?? 'Ocurrió un error inesperado',
          statusCode: statusCode,
        );
    }
  }

  @override
  String toString() => 'ApiException(type: $type, message: $message, statusCode: $statusCode)';
}
