import 'package:simcore_frontend/core/network/api_client.dart';

class AnalysisRemoteDataSource {
  AnalysisRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>?> getAnalysis({
    required int companyId,
    String scenarioType = 'PROBABLE',
  }) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId/analysis',
      queryParameters: {'scenarioType': scenarioType},
    );
    return result.fold(
      (e) => throw e,
      (data) => data != null ? Map<String, dynamic>.from(data as Map) : null,
    );
  }

  Future<Map<String, dynamic>?> getFinancialIndicators({
    required int companyId,
    String scenarioType = 'PROBABLE',
  }) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId/financial-indicators',
      queryParameters: {'scenarioType': scenarioType},
    );
    return result.fold(
      (e) => throw e,
      (data) => data != null ? Map<String, dynamic>.from(data as Map) : null,
    );
  }

  Future<List<Map<String, dynamic>>> getIncoherences({
    required int companyId,
    String scenarioType = 'PROBABLE',
  }) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId/incoherences',
      queryParameters: {'scenarioType': scenarioType},
    );
    return result.fold(
      (e) => throw e,
      (data) => _extractList(data),
    );
  }

  Future<Map<String, dynamic>?> getNarrativeReport({
    required int companyId,
    String scenarioType = 'PROBABLE',
  }) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId/report',
      queryParameters: {'scenarioType': scenarioType},
    );
    return result.fold(
      (e) => throw e,
      (data) => data != null ? Map<String, dynamic>.from(data as Map) : null,
    );
  }

  Future<void> completeModule({required int companyId}) async {
    final result = await _apiClient.patch(
      '/api/v1/simulation/companies/$companyId/modules/ANALYSIS/complete',
    );
    result.fold((e) => throw e, (_) {});
  }

  Future<Map<String, dynamic>?> getIncrementalAnalysis({
    required int companyId,
    String scenarioType = 'PROBABLE',
  }) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId/incremental',
      queryParameters: {'scenarioType': scenarioType},
    );
    return result.fold(
      (e) => throw e,
      (data) => data != null ? Map<String, dynamic>.from(data as Map) : null,
    );
  }

  Future<Map<String, dynamic>?> saveIncrementalAnalysis({
    required int companyId,
    required Map<String, dynamic> body,
  }) async {
    final result = await _apiClient.put(
      '/api/v1/simulation/companies/$companyId/incremental',
      data: body,
    );
    return result.fold(
      (e) => throw e,
      (data) => data != null ? Map<String, dynamic>.from(data as Map) : null,
    );
  }

  Future<Map<String, dynamic>?> getAiViability({required int companyId}) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId/ai-sim/viability',
    );
    return result.fold(
      (e) => throw e,
      (data) => data != null ? Map<String, dynamic>.from(data as Map) : null,
    );
  }

  Future<Map<String, dynamic>?> getAiAdoption({
    required int companyId,
    required double price,
    required double marketingBudget,
    required String channel,
  }) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId/ai-sim/adoption',
      queryParameters: {
        'price': price,
        'marketingBudget': marketingBudget,
        'channel': channel,
      },
    );
    return result.fold(
      (e) => throw e,
      (data) => data != null ? Map<String, dynamic>.from(data as Map) : null,
    );
  }

  Future<Map<String, dynamic>?> getAiStressTest({
    required int companyId,
    required double vanEstimado,
  }) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId/ai-sim/stress-test',
      queryParameters: {'vanEstimado': vanEstimado},
    );
    return result.fold(
      (e) => throw e,
      (data) => data != null ? Map<String, dynamic>.from(data as Map) : null,
    );
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is Map) {
      final json = Map<String, dynamic>.from(data);
      for (final key in ['data', 'content', 'items', 'incoherences']) {
        final value = json[key];
        if (value is List) {
          return value
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    }
    return const [];
  }
}
