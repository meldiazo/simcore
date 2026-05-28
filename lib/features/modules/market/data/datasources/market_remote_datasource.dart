import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/features/modules/market/data/models/market_assumption_model.dart';
import 'package:simcore_frontend/features/modules/market/data/models/sales_projection_model.dart';
import 'package:simcore_frontend/features/modules/market/domain/entities/market_assumption.dart';
import 'package:simcore_frontend/features/modules/market/domain/entities/sales_projection.dart';

class MarketRemoteDataSource {
  MarketRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<MarketAssumption?> getAssumption({required int companyId}) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId/market/assumption',
    );
    return result.fold(
      (e) => throw e,
      (data) {
        if (data == null) return null;
        return MarketAssumptionModel.fromJson(Map<String, dynamic>.from(data as Map));
      },
    );
  }

  Future<MarketAssumption> saveAssumption({
    required int companyId,
    required Map<String, dynamic> data,
  }) async {
    final result = await _apiClient.put(
      '/api/v1/simulation/companies/$companyId/market/assumption',
      data: data,
    );
    return result.fold(
      (e) => throw e,
      (d) => MarketAssumptionModel.fromJson(Map<String, dynamic>.from(d as Map)),
    );
  }

  Future<SalesProjection?> getProjection({required int companyId}) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId/market/projection',
    );
    return result.fold(
      (e) => throw e,
      (data) {
        if (data == null) return null;
        return SalesProjectionModel.fromJson(Map<String, dynamic>.from(data as Map));
      },
    );
  }

  Future<SalesProjection> generateProjection({required int companyId, int months = 12}) async {
    final result = await _apiClient.post(
      '/api/v1/simulation/companies/$companyId/market/projection/generate',
      data: {'months': months},
    );
    return result.fold(
      (e) => throw e,
      (d) => SalesProjectionModel.fromJson(Map<String, dynamic>.from(d as Map)),
    );
  }

  Future<void> completeModule({required int companyId}) async {
    final result = await _apiClient.patch(
      '/api/v1/simulation/companies/$companyId/market/complete',
    );
    result.fold((e) => throw e, (_) {});
  }
}
