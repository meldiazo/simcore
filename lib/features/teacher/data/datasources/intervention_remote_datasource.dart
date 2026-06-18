import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/features/teacher/data/models/intervention_model.dart';

class InterventionRemoteDataSource {
  InterventionRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<InterventionModel>> listInterventions({
    required int companyId,
  }) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId/interventions',
    );
    return result.fold(
      (e) => throw e,
      (data) {
        if (data is! List) return const [];
        return data
            .whereType<Map>()
            .map(
                (e) => InterventionModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false);
      },
    );
  }

  Future<InterventionModel> createIntervention({
    required int companyId,
    required CreateInterventionRequest request,
  }) async {
    final result = await _apiClient.post(
      '/api/v1/simulation/companies/$companyId/interventions',
      data: request.toJson(),
    );
    return result.fold(
      (e) => throw e,
      (data) =>
          InterventionModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }
}
