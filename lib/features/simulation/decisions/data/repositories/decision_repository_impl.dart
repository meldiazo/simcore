import 'package:simcore_frontend/features/simulation/decisions/data/datasources/decision_remote_datasource.dart';
import 'package:simcore_frontend/features/simulation/decisions/repositories/decision_repository.dart';
import '../models/decision_model.dart';
import '../models/decision_impact_model.dart';

class DecisionRepositoryImpl implements DecisionRepository {
  final DecisionRemoteDataSource remoteDatasource;

  DecisionRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<DecisionModel>> getDecisions(String companyId, String module) async {
    return await remoteDatasource.getDecisions(companyId, module);
  }

  @override
  Future<DecisionModel> createDecision(DecisionModel decision) async {
    return await remoteDatasource.createDecision(decision);
  }

  @override
  Future<List<DecisionModel>> getCompanyDecisions(String companyId) async {
    return await remoteDatasource.getCompanyDecisions(companyId);
  }

  @override
  Future<List<DecisionModel>> getDecisionHistory(String companyId, String module, String decisionType) async {
    return await remoteDatasource.getDecisionHistory(companyId, module, decisionType);
  }

  @override
  Future<List<DecisionImpactModel>> getDecisionImpact(String decisionId) async {
    return await remoteDatasource.getDecisionImpact(decisionId);
  }
}
