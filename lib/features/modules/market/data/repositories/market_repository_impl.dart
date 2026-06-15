import 'package:simcore_frontend/features/modules/market/domain/entities/repositories/market_repository.dart';
import '../datasources/market_remote_datasource.dart';
import '../models/market_assumption_model.dart';
import '../models/sales_projection_model.dart';

class MarketRepositoryImpl implements MarketRepository {
  final MarketRemoteDatasource remoteDatasource;

  MarketRepositoryImpl({required this.remoteDatasource});

  @override
  Future<MarketAssumptionModel?> getAssumption(String companyId) async =>
      await remoteDatasource.getAssumption(companyId);

  @override
  Future<MarketAssumptionModel> updateAssumption(
          String companyId, MarketAssumptionModel assumption) async =>
      await remoteDatasource.updateAssumption(companyId, assumption);

  @override
  Future<SalesProjectionModel?> getProjection(String companyId) async =>
      await remoteDatasource.getProjection(companyId);

  @override
  Future<SalesProjectionModel> generateProjection(
    String companyId, {
    required String scenarioType,
  }) async =>
      await remoteDatasource.generateProjection(
        companyId,
        scenarioType: scenarioType,
      );

  @override
  Future<void> completeMarket(String companyId) async =>
      await remoteDatasource.completeMarket(companyId);
}
