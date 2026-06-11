import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';

class ReportsRemoteDataSource {
  const ReportsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> getCompanyReport({
    required int companyId,
    String scenarioType = 'PROBABLE',
  }) async {
    final result = await _client.get(
      '/api/v1/simulation/companies/$companyId/report',
      queryParameters: {'scenarioType': scenarioType},
    );
    return result.fold(
      (e) => throw Exception(e.message),
      (data) => Map<String, dynamic>.from(data as Map),
    );
  }

  Future<List<int>> exportCompanyPdf({
    required int companyId,
    String scenarioType = 'PROBABLE',
  }) async {
    final result = await _client.get(
      '/api/v1/simulation/companies/$companyId/export/pdf',
      queryParameters: {'scenarioType': scenarioType},
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          'Accept': 'application/pdf',
        },
      ),
    );
    return result.fold(
      (e) => throw Exception(e.message),
      (data) => List<int>.from(data as List),
    );
  }

  Future<List<int>> exportCourseCsv({
    required int courseId,
    String scenarioType = 'PROBABLE',
  }) async {
    final result = await _client.get(
      '/api/v1/simulation/courses/$courseId/export/csv',
      queryParameters: {'scenarioType': scenarioType},
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          'Accept': 'text/csv',
        },
      ),
    );
    return result.fold(
      (e) => throw Exception(e.message),
      (data) => List<int>.from(data as List),
    );
  }
}

final reportsDataSourceProvider = Provider<ReportsRemoteDataSource>((ref) {
  return ReportsRemoteDataSource(ref.watch(simulationApiClientProvider));
});
