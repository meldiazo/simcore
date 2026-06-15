import 'package:simcore_frontend/features/modules/market/data/models/market_assumption_model.dart';
import 'package:simcore_frontend/features/modules/market/data/models/sales_projection_model.dart';

abstract class MarketRepository {
  Future<MarketAssumptionModel?> getAssumption(String companyId);

  Future<MarketAssumptionModel> updateAssumption(
      String companyId, MarketAssumptionModel assumption);

  Future<SalesProjectionModel?> getProjection(String companyId);

  Future<SalesProjectionModel> generateProjection(
    String companyId, {
    required String scenarioType,
  });

  Future<void> completeMarket(String companyId);
}
