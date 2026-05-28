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
      (data) => data != null ? Map<String, dynamic>.from(data as Map) : {},
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
      (data) => data != null ? Map<String, dynamic>.from(data as Map) : {},
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
      (data) => data != null ? Map<String, dynamic>.from(data as Map) : {},
    );
  }

  Future<Map<String, dynamic>> markRequiresRevision({
    required int companyId,
    required String module,
    required String message,
  }) async {
    final result = await _apiClient.patch(
      '/api/v1/simulation/companies/$companyId/modules/$module/requires-revision',
      data: {'message': message},
    );
    return result.fold(
      (e) => throw e,
      (data) => data != null ? Map<String, dynamic>.from(data as Map) : {},
    );
  }
}
