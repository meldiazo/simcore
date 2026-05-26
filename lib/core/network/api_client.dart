import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';

import 'api_exception.dart';
import 'api_result.dart';

class ApiClient {
  ApiClient({
    required String baseUrl,
    TokenProvider? tokenProvider,
    RefreshCallback? onRefresh,
    VoidCallback? onSessionExpired,
  })  : _tokenProvider = tokenProvider,
        _onRefresh = onRefresh,
        _onSessionExpired = onSessionExpired {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final isPublic = _isPublicRoute(options.path);
          if (!isPublic && _tokenProvider != null) {
            final token = await _tokenProvider!();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          final is401 = error.response?.statusCode == 401;
          final isRefreshRoute = error.requestOptions.path.contains('/auth/refresh');
          final isLoginRoute = error.requestOptions.path.contains('/auth/login');

          if (is401 && !isRefreshRoute && !isLoginRoute && _onRefresh != null) {
            try {
              final newToken = await _onRefresh!();
              if (newToken != null) {
                final opts = error.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newToken';
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              }
            } catch (_) {
              _onSessionExpired?.call();
            }
          }

          return handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (o) => debugPrint(o.toString()),
        ),
      );
    }
  }

  late final Dio _dio;
  final TokenProvider? _tokenProvider;
  final RefreshCallback? _onRefresh;
  final VoidCallback? _onSessionExpired;

  static bool _isPublicRoute(String path) {
  return path.contains('/auth/login') ||
      path.contains('/auth/refresh') ||
      path.contains('/actuator/health') ||
      path.contains('/v3/api-docs') ||
      path.contains('/swagger-ui') ||
      path.contains('/.well-known/jwks.json');
}

  Future<ApiResult<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _safeRequest(
      () => _dio.get(path, queryParameters: queryParameters, options: options),
    );
  }

  Future<ApiResult<dynamic>> post(String path, {dynamic data, Options? options}) async {
    return _safeRequest(() => _dio.post(path, data: data, options: options));
  }

  Future<ApiResult<dynamic>> put(String path, {dynamic data, Options? options}) async {
    return _safeRequest(() => _dio.put(path, data: data, options: options));
  }

  Future<ApiResult<dynamic>> patch(String path, {dynamic data, Options? options}) async {
    return _safeRequest(() => _dio.patch(path, data: data, options: options));
  }

  Future<ApiResult<dynamic>> delete(String path, {dynamic data, Options? options}) async {
    return _safeRequest(() => _dio.delete(path, data: data, options: options));
  }

  Future<ApiResult<dynamic>> _safeRequest(Future<Response> Function() requestFn) async {
    try {
      final response = await requestFn();
      return Right(response.data);
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
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
    }

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError =>
        ApiException(type: ErrorType.network, message: 'Error de conexión. Revisa tu internet.'),
      DioExceptionType.cancel =>
        ApiException(type: ErrorType.unknown, message: 'Petición cancelada.'),
      _ => ApiException(type: ErrorType.unknown, message: error.message ?? 'Error desconocido.'),
    };
  }
}

typedef TokenProvider = Future<String?> Function();
typedef RefreshCallback = Future<String?> Function();
