import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/features/teacher/data/models/evaluation_model.dart';

class EvaluationRemoteDataSource {
  EvaluationRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<EvaluationModel>> listEvaluations({required int courseId}) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/courses/$courseId/evaluations',
    );
    return result.fold(
      (e) => throw e,
      (data) {
        if (data is! List) return const [];
        return data
            .whereType<Map>()
            .map((e) => EvaluationModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false);
      },
    );
  }

  Future<EvaluationModel?> getEvaluation({
    required int courseId,
    required int groupId,
  }) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/courses/$courseId/evaluations/groups/$groupId',
    );
    return result.fold(
      (e) => throw e,
      (data) {
        if (data == null) return null;
        if (data is! Map) return null;
        return EvaluationModel.fromJson(Map<String, dynamic>.from(data));
      },
    );
  }

  Future<EvaluationModel> upsertEvaluation({
    required int courseId,
    required int groupId,
    required UpsertEvaluationRequest request,
  }) async {
    final result = await _apiClient.put(
      '/api/v1/simulation/courses/$courseId/evaluations/groups/$groupId',
      data: request.toJson(),
    );
    return result.fold(
      (e) => throw e,
      (data) =>
          EvaluationModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }
}
