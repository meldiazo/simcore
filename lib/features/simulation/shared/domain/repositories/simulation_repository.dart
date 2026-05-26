import 'package:simcore_frontend/features/shared/data/demo/simcore_demo_data.dart';

abstract class SimulationRepository {
  Future<StudentUser> getCurrentUser();

  Future<CurrentCycle> getCurrentCycle();

  Future<List<TeamMember>> getTeamMembers();

  Future<List<KpiMetric>> getKpis();

  Future<List<AlertItem>> getAlerts();

  Future<List<DecisionModule>> getDecisionModules({
    int companyId = 1,
  });

  Future<List<RankingTeam>> getRanking();

  Future<List<MarketSegment>> getMarketSegments();

  Future<List<Competitor>> getCompetitors();

  Future<List<ScenarioData>> getFinancialScenarios();

  Future<List<CashFlowEntry>> getCashFlow();

  Future<List<Inefficiency>> getOrganizationalInefficiencies();

  Future<List<AdminTeamStatus>> getAdminTeams();
}
