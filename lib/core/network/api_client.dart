import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';

import 'api_exception.dart';
import 'api_result.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({required String baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
      ),
    );

    // Interceptor para inyectar el Bearer token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // TODO: Obtener el token del gestor de estado (ej. Riverpod) o SecureStorage
          // Simulando la obtención del token
          const String? accessToken = null; 

          // No inyectar el token en la ruta de login
          final isLoginRequest = options.path.contains('/api/v1/iam/auth/login');

          if (accessToken != null && !isLoginRequest) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          
          return handler.next(options);
        },
      ),
    );

    // Interceptor de Logs solo en modo de desarrollo
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  Future<ApiResult<dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return _safeRequest(() => _dio.get(path, queryParameters: queryParameters));
  }

  Future<ApiResult<dynamic>> post(String path, {dynamic data}) async {
    return _safeRequest(() => _dio.post(path, data: data));
  }

  Future<ApiResult<dynamic>> put(String path, {dynamic data}) async {
    return _safeRequest(() => _dio.put(path, data: data));
  }

  Future<ApiResult<dynamic>> patch(String path, {dynamic data}) async {
    return _safeRequest(() => _dio.patch(path, data: data));
  }

  Future<ApiResult<dynamic>> delete(String path, {dynamic data}) async {
    return _safeRequest(() => _dio.delete(path, data: data));
  }

  /// Ejecuta la petición de forma segura y encapsula el resultado en [ApiResult]
  Future<ApiResult<dynamic>> _safeRequest(Future<Response> Function() requestFn) async {
    try {
      final response = await requestFn();
      // Retornamos Right (Success) con la data
      return Right(response.data);
    } on DioException catch (e) {
      // Retornamos Left (Failure) mapeando el error de Dio a ApiException
      return Left(_handleDioException(e));
    } catch (e) {
      // Capturamos cualquier otro error imprevisto
      return Left(
        ApiException(
          type: ErrorType.unknown,
          message: 'Error inesperado: ${e.toString()}',
        ),
      );
    }
  }

  ApiException _handleDioException(DioException error) {
    if (error.response != null) {
      final statusCode = error.response?.statusCode;
      final responseData = error.response?.data;
      
      String? errorMessage;
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] as String?;
      }

      return ApiException.fromStatusCode(statusCode, errorMessage ?? error.message);
    } else {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return ApiException(
            type: ErrorType.network,
            message: 'Error de conexión. Revisa tu internet.',
          );
        case DioExceptionType.cancel:
          return ApiException(
            type: ErrorType.unknown,
            message: 'Petición cancelada.',
          );
        default:
          return ApiException(
            type: ErrorType.unknown,
            message: error.message ?? 'Error desconocido en la red.',
          );
      }
    }
  }
}
