import 'package:simcore_frontend/features/shared/data/demo/simcore_demo_data.dart';
import 'package:simcore_frontend/features/simulation/shared/domain/entities/simulation_context.dart';

abstract class SimulationDataSource {
  Future<StudentUser> getCurrentUser();

  Future<CurrentCycle> getCurrentCycle();

  Future<List<TeamMember>> getTeamMembers();

  Future<List<KpiMetric>> getKpis();

  Future<List<AlertItem>> getAlerts();

  Future<List<ModuleProgress>> getModuleProgress({
    int companyId = 1,
  });

  Future<List<RankingTeam>> getRanking();

  Future<List<MarketSegment>> getMarketSegments();

  Future<List<Competitor>> getCompetitors();

  Future<List<ScenarioData>> getFinancialScenarios();

  Future<List<CashFlowEntry>> getCashFlow();

  Future<List<Inefficiency>> getOrganizationalInefficiencies();

  Future<List<AdminTeamStatus>> getAdminTeams();
  Future<SimulationContext> getSimulationContext({required int companyId});
  Future<SimulationContext> getSimulationContextByGroupId({required int groupId});
}
