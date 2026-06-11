import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/models/decision_impact_model.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/models/decision_model.dart';

class DecisionRemoteDatasource {
  DecisionRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<DecisionModel>> getDecisions(String companyId, String module) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/decisions',
      queryParameters: {
        'companyId': _tryInt(companyId) ?? companyId,
        'module': module,
      },
    );

    return result.fold(
      (e) => throw e,
      (data) => _extractList(data).map(DecisionModel.fromJson).toList(),
    );
  }

  Future<DecisionModel> createDecision(DecisionModel decision) async {
    final result = await _apiClient.post(
      '/api/v1/simulation/decisions',
      data: decision.toJson(),
    );

    return result.fold(
      (e) => throw e,
      (data) {
        if (data is Map) {
          return DecisionModel.fromJson(Map<String, dynamic>.from(data));
        }

        // Si el backend responde vacío/texto, no tumbamos la app.
        return decision;
      },
    );
  }

  Future<List<DecisionModel>> getCompanyDecisions(String companyId) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/decisions/company/$companyId',
    );

    return result.fold(
      (e) => throw e,
      (data) => _extractList(data).map(DecisionModel.fromJson).toList(),
    );
  }

  Future<List<DecisionModel>> getDecisionHistory(
    String companyId,
    String module,
    String decisionType,
  ) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/decisions/history',
      queryParameters: {
        'companyId': _tryInt(companyId) ?? companyId,
        'module': module,
        'decisionType': decisionType,
      },
    );

    return result.fold(
      (e) => throw e,
      (data) => _extractList(data).map(DecisionModel.fromJson).toList(),
    );
  }

  Future<List<DecisionImpactModel>> getDecisionImpact(String decisionId) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/decisions/$decisionId/impact',
    );

    return result.fold(
      (e) => throw e,
      (data) => _extractList(data).map(DecisionImpactModel.fromJson).toList(),
    );
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data == null) return const [];

    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (data is Map) {
      final json = Map<String, dynamic>.from(data);

      for (final key in ['data', 'content', 'items', 'decisions']) {
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

  int? _tryInt(String value) {
    return int.tryParse(value);
  }
}