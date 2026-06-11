import 'package:simcore_frontend/core/network/api_client.dart';

class ModuleProgressRemoteDataSource {
  ModuleProgressRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> startModule({
    required int companyId,
    required String module,
  }) async {
    final result = await _apiClient.patch(
      '/api/v1/simulation/companies/$companyId/modules/$module/start',
    );

    return result.fold(
      (e) => throw e,
      _safeMap,
    );
  }

  Future<Map<String, dynamic>> completeModule({
    required int companyId,
    required String module,
  }) async {
    final result = await _apiClient.patch(
      '/api/v1/simulation/companies/$companyId/modules/$module/complete',
    );

    return result.fold(
      (e) => throw e,
      _safeMap,
    );
  }

  Future<Map<String, dynamic>> lockModule({
    required int companyId,
    required String module,
    required bool locked,
  }) async {
    final result = await _apiClient.patch(
      '/api/v1/simulation/companies/$companyId/modules/$module/lock',
      data: {'locked': locked},
    );

    return result.fold(
      (e) => throw e,
      _safeMap,
    );
  }

  Future<Map<String, dynamic>> markRequiresRevision({
    required int companyId,
    required String module,
    required String message,
  }) async {
    final result = await _apiClient.patch(
      '/api/v1/simulation/companies/$companyId/modules/$module/requires-revision',
      data: {'reason': message},
    );

    return result.fold(
      (e) => throw e,
      _safeMap,
    );
  }

  Map<String, dynamic> _safeMap(dynamic data) {
    if (data == null) return <String, dynamic>{};

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    // Algunos PATCH pueden devolver texto o body vacío.
    // Eso no debe tumbar Flutter.
    return <String, dynamic>{};
  }
}