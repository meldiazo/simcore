import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';

class ComparisonRemoteDataSource {
  const ComparisonRemoteDataSource(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> getCourseComparison({
    required int courseId,
    required String scenarioType,
  }) async {
    final result = await _client.get(
      '/api/v1/simulation/courses/$courseId/comparison',
      queryParameters: {'scenarioType': scenarioType},
    );
    return result.fold(
      (e) => throw Exception(e.message),
      (data) => Map<String, dynamic>.from(data as Map),
    );
  }
}

final comparisonDataSourceProvider = Provider<ComparisonRemoteDataSource>((ref) {
  return ComparisonRemoteDataSource(ref.watch(simulationApiClientProvider));
});
