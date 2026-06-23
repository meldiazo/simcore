String toUserFriendlyError(dynamic error) {
  if (error == null) return '';
  final str = error.toString().trim();
  if (str.isEmpty) return 'Ha ocurrido un error inesperado.';

  final lower = str.toLowerCase();

  // DB Uniqueness & Validation
  if (lower.contains('el codigo del curso ya existe') || lower.contains('curso ya existe')) {
    return 'El código de este curso ya está registrado. Por favor, utiliza otro código (ej: ADM-102).';
  }
  if (lower.contains('el nombre del curso ya existe')) {
    return 'El nombre de este curso ya está registrado.';
  }
  if (lower.contains('el nombre del grupo ya existe') || lower.contains('grupo ya existe')) {
    return 'El nombre de este grupo ya está registrado en este curso. Intente con otro nombre.';
  }
  if (lower.contains('el codigo del escenario ya existe') || lower.contains('escenario ya existe')) {
    return 'El código de escenario ya está en uso. Por favor, especifica un código único.';
  }
  if (lower.contains('company already exists') || lower.contains('la empresa ya existe') || lower.contains('empresa ya existe')) {
    return 'El grupo ya tiene una empresa activa asignada.';
  }

  // Auth Errors
  if (lower.contains('bad credentials') || lower.contains('invalid credentials') || lower.contains('credenciales incorrectas') || lower.contains('usuario o contraseña incorrectos')) {
    return 'Usuario o contraseña incorrectos. Por favor, verifica tus credenciales.';
  }
  if (lower.contains('access denied') || lower.contains('forbidden') || lower.contains('unauthorized') || lower.contains('403') || lower.contains('401')) {
    return 'No tienes permisos para realizar esta acción o tu sesión ha expirado.';
  }

  // Network / Connection
  if (lower.contains('socketexception') || lower.contains('connection refused') || lower.contains('network') || lower.contains('failed to connect') || lower.contains('connection timeout')) {
    return 'Error de conexión. Por favor, verifica tu conexión a internet o que el servidor esté activo.';
  }

  // General HTTP status errors
  if (lower.contains('400') || lower.contains('bad request')) {
    return 'La solicitud es inválida. Asegúrate de haber completado todos los campos requeridos.';
  }
  if (lower.contains('404') || lower.contains('not found')) {
    return 'El recurso solicitado no fue encontrado.';
  }
  if (lower.contains('500') || lower.contains('internal server error') || lower.contains('server error')) {
    return 'Error interno del servidor. Por favor, contacta a soporte o inténtalo más tarde.';
  }

  // Clean raw exceptions prefixes
  var cleanMsg = str;
  if (cleanMsg.startsWith('Exception: ')) {
    cleanMsg = cleanMsg.substring(11);
  }
  if (cleanMsg.startsWith('Exception:')) {
    cleanMsg = cleanMsg.substring(10);
  }

  if (cleanMsg.contains('DioException')) {
    if (lower.contains('status code 409') || lower.contains('conflict')) {
      return 'Conflicto: El registro que intentas crear ya existe o colisiona con otro.';
    }
    if (lower.contains('status code 400')) {
      return 'Los datos ingresados no son correctos o están incompletos.';
    }
    return 'Ocurrió un inconveniente al comunicarse con el servidor. Inténtalo de nuevo.';
  }

  return cleanMsg;
}
