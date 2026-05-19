import 'package:dartz/dartz.dart';
import 'api_exception.dart';

/// Define el tipo para todas las respuestas de la API y repositorios.
/// [Left] representa un [ApiException] (Failure).
/// [Right] representa el valor exitoso de tipo [T] (Success).
typedef ApiResult<T> = Either<ApiException, T>;
