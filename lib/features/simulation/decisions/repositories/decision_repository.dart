import 'package:simcore_frontend/features/simulation/decisions/data/models/decision_impact_model.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/models/decision_model.dart';


abstract class DecisionRepository {
  Future<List<DecisionModel>> getDecisions(String companyId, String module);
  
  Future<DecisionModel> createDecision(DecisionModel decision);
  
  Future<List<DecisionModel>> getCompanyDecisions(String companyId);
  
  Future<List<DecisionModel>> getDecisionHistory(String companyId, String module, String decisionType);
  
  Future<List<DecisionImpactModel>> getDecisionImpact(String decisionId);
}