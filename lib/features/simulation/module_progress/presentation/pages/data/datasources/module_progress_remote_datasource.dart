import 'package:simcore_frontend/core/network/api_client.dart';

class ModuleProgressRemoteDatasource {
  ModuleProgressRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> patchModuleAction(
      String companyId, String module, String action) async {
    final result = await _apiClient.patch(
      '/api/v1/simulation/companies/$companyId/modules/$module/$action',
    );

    return result.fold(
      (exception) => throw exception,
      (data) => data == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(data as Map),
    );
  }
}
