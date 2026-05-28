import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/models/decision_model.dart';
import 'package:simcore_frontend/features/simulation/decisions/domain/entities/decision.dart';

class DecisionRemoteDataSource {
  DecisionRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Decision>> getDecisionsByCompany({required int companyId}) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/decisions/company/$companyId',
    );
    return result.fold(
      (e) => throw e,
      (data) => _extractList(data).map(DecisionModel.fromJson).toList(),
    );
  }

  Future<List<Decision>> getDecisionsByModule({
    required int companyId,
    required String module,
  }) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/decisions',
      queryParameters: {'companyId': companyId, 'module': module},
    );
    return result.fold(
      (e) => throw e,
      (data) => _extractList(data).map(DecisionModel.fromJson).toList(),
    );
  }

  Future<Decision> createDecision({required Map<String, dynamic> data}) async {
    final result = await _apiClient.post('/api/v1/simulation/decisions', data: data);
    return result.fold(
      (e) => throw e,
      (d) => DecisionModel.fromJson(Map<String, dynamic>.from(d as Map)),
    );
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (data is Map) {
      final json = Map<String, dynamic>.from(data);
      for (final key in ['data', 'content', 'items', 'decisions']) {
        final value = json[key];
        if (value is List) {
          return value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    }
    return const [];
  }
}
