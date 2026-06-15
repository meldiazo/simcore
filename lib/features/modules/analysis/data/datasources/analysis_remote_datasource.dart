import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/features/modules/analysis/data/models/consolidated_analysis_model.dart';

class AnalysisRemoteDataSource {
  AnalysisRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<ConsolidatedAnalysisModel?> getAnalysis({
    required int companyId,
    required String scenarioType,
  }) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId/analysis',
      queryParameters: {'scenarioType': scenarioType},
    );
    return result.fold(
      (e) => throw e,
      (data) => data != null
          ? ConsolidatedAnalysisModel.fromJson(
              Map<String, dynamic>.from(data as Map),
            )
          : null,
    );
  }

  Future<Map<String, dynamic>?> getFinancialIndicators({
    required int companyId,
    required String scenarioType,
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
    required String scenarioType,
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
    required String scenarioType,
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
      '/api/v1/simulation/companies/$companyId/analysis/complete',
    );
    result.fold((e) => throw e, (_) {});
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
