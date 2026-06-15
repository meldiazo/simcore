import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/core/network/api_exception.dart';
import 'package:simcore_frontend/features/modules/market/data/models/market_assumption_model.dart';
import 'package:simcore_frontend/features/modules/market/data/models/sales_projection_model.dart';

class MarketRemoteDatasource {
  MarketRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<MarketAssumptionModel?> getAssumption(String companyId) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId/market/assumption',
    );

    return result.fold(
      (failure) {
        if (failure.type == ErrorType.notFound) {
          return null;
        }
        throw failure;
      },
      (data) {
        if (data == null) return null;
        if (data is Map) {
          return MarketAssumptionModel.fromJson(
            Map<String, dynamic>.from(data),
          );
        }
        return null;
      },
    );
  }

  Future<MarketAssumptionModel> updateAssumption(
    String companyId,
    MarketAssumptionModel assumption,
  ) async {
    final result = await _apiClient.put(
      '/api/v1/simulation/companies/$companyId/market/assumption',
      data: assumption.toJson(),
    );

    return result.fold(
      (failure) => throw failure,
      (data) {
        if (data is Map) {
          return MarketAssumptionModel.fromJson(
            Map<String, dynamic>.from(data),
          );
        }

        return assumption;
      },
    );
  }

  Future<SalesProjectionModel?> getProjection(String companyId) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId/market/projection',
    );

    return result.fold(
      (failure) {
        if (failure.type == ErrorType.notFound) {
          return null;
        }
        throw failure;
      },
      (data) {
        if (data == null) return null;
        if (data is Map) {
          return SalesProjectionModel.fromJson(
            Map<String, dynamic>.from(data),
          );
        }
        return null;
      },
    );
  }

  Future<SalesProjectionModel> generateProjection(
    String companyId, {
    required String scenarioType,
  }) async {
    final result = await _apiClient.post(
      '/api/v1/simulation/companies/$companyId/market/projection/generate',
      data: {
        'companyId': int.tryParse(companyId) ?? companyId,
        'scenarioType': scenarioType,
      },
    );

    return result.fold(
      (failure) => throw failure,
      (data) {
        if (data is Map) {
          return SalesProjectionModel.fromJson(
            Map<String, dynamic>.from(data),
          );
        }

        throw StateError('El backend no devolvió una proyección válida.');
      },
    );
  }

  Future<void> completeMarket(String companyId) async {
    final result = await _apiClient.patch(
      '/api/v1/simulation/companies/$companyId/market/complete',
    );

    result.fold(
      (failure) => throw failure,
      (_) => null,
    );
  }
}
