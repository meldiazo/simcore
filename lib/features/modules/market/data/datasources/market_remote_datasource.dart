import 'package:simcore_frontend/core/network/api_client.dart';
import '../models/market_assumption_model.dart';
import '../models/sales_projection_model.dart';

class MarketRemoteDatasource {
  MarketRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<MarketAssumptionModel?> getAssumption(String companyId) async {
    final result = await _apiClient
        .get('/api/v1/simulation/companies/$companyId/market/assumption');
    return result.fold(
      (exception) => throw exception,
      (data) {
        if (data == null) return null;
        return MarketAssumptionModel.fromJson(
            Map<String, dynamic>.from(data as Map));
      },
    );
  }

  Future<MarketAssumptionModel> updateAssumption(
      String companyId, MarketAssumptionModel assumption) async {
    final result = await _apiClient.put(
      '/api/v1/simulation/companies/$companyId/market/assumption',
      data: assumption.toJson(),
    );
    return result.fold(
      (exception) => throw exception,
      (data) => MarketAssumptionModel.fromJson(
          Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<SalesProjectionModel?> getProjection(String companyId) async {
    final result = await _apiClient
        .get('/api/v1/simulation/companies/$companyId/market/projection');
    return result.fold(
      (exception) => throw exception,
      (data) {
        if (data == null) return null;
        return SalesProjectionModel.fromJson(
            Map<String, dynamic>.from(data as Map));
      },
    );
  }

  Future<SalesProjectionModel> generateProjection(String companyId) async {
    final result = await _apiClient.post(
      '/api/v1/simulation/companies/$companyId/market/projection/generate',
    );
    return result.fold(
      (exception) => throw exception,
      (data) =>
          SalesProjectionModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<void> completeMarket(String companyId) async {
    final result = await _apiClient.patch(
      '/api/v1/simulation/companies/$companyId/market/complete',
    );
    result.fold((exception) => throw exception, (_) => null);
  }
}
