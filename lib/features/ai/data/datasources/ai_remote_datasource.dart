import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/features/ai/data/models/ai_suggestion_model.dart';

class AiRemoteDataSource {
  AiRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<AiSuggestionModel> validateMarket({required int companyId}) {
    return _getSuggestion(
        '/api/v1/simulation/companies/$companyId/ai/validate-market');
  }

  Future<AiSuggestionModel> explainRatios({
    required int companyId,
    String scenarioType = 'PROBABLE',
  }) {
    return _getSuggestion(
      '/api/v1/simulation/companies/$companyId/ai/explain-ratios',
      queryParameters: {'scenarioType': scenarioType},
    );
  }

  Future<AiSuggestionModel> defenseQuestions({
    required int companyId,
    String scenarioType = 'PROBABLE',
  }) {
    return _getSuggestion(
      '/api/v1/simulation/companies/$companyId/ai/defense-questions',
      queryParameters: {'scenarioType': scenarioType},
    );
  }

  Future<AiSuggestionModel> narrative({
    required int companyId,
    String scenarioType = 'PROBABLE',
  }) {
    return _getSuggestion(
      '/api/v1/simulation/companies/$companyId/ai/narrative',
      queryParameters: {'scenarioType': scenarioType},
    );
  }

  Future<AiSuggestionModel> _getSuggestion(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final result = await _apiClient.get(path, queryParameters: queryParameters);
    return result.fold(
      (e) => throw e,
      (data) =>
          AiSuggestionModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }
}
