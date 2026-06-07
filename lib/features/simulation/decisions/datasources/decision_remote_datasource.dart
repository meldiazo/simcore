import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/models/decision_impact_model.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/models/decision_model.dart';

class DecisionRemoteDatasource {
  DecisionRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<DecisionModel>> getDecisions(
      String companyId, String module) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/decisions',
      queryParameters: {'companyId': companyId, 'module': module},
    );
    return result.fold(
      (exception) => throw exception,
      (data) => _extractList(data).map(DecisionModel.fromJson).toList(),
    );
  }

  Future<DecisionModel> createDecision(DecisionModel decision) async {
    final result = await _apiClient.post(
      '/api/v1/simulation/decisions',
      data: decision.toJson(),
    );
    return result.fold(
      (exception) => throw exception,
      (data) => DecisionModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<List<DecisionModel>> getCompanyDecisions(String companyId) async {
    final result =
        await _apiClient.get('/api/v1/simulation/decisions/company/$companyId');
    return result.fold(
      (exception) => throw exception,
      (data) => _extractList(data).map(DecisionModel.fromJson).toList(),
    );
  }

  Future<List<DecisionModel>> getDecisionHistory(
      String companyId, String module, String decisionType) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/decisions/history',
      queryParameters: {
        'companyId': companyId,
        'module': module,
        'decisionType': decisionType,
      },
    );
    return result.fold(
      (exception) => throw exception,
      (data) => _extractList(data).map(DecisionModel.fromJson).toList(),
    );
  }

  Future<List<DecisionImpactModel>> getDecisionImpact(String decisionId) async {
    final result =
        await _apiClient.get('/api/v1/simulation/decisions/$decisionId/impact');
    return result.fold(
      (exception) => throw exception,
      (data) => _extractList(data).map(DecisionImpactModel.fromJson).toList(),
    );
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (data is Map) {
      final json = Map<String, dynamic>.from(data);
      for (final key in ['data', 'content', 'items', 'decisions', 'impacts']) {
        final value = json[key];
        if (value is List) {
          return value
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }
    }
    return const [];
  }
}
