import 'package:simcore_frontend/features/shared/data/demo/simcore_demo_data.dart';
import 'package:simcore_frontend/features/simulation/shared/data/datasources/simulation_data_source.dart';

class SimulationMockDataSource implements SimulationDataSource {
  @override
  Future<StudentUser> getCurrentUser() async => studentUser;

  @override
  Future<CurrentCycle> getCurrentCycle() async => currentCycle;

  @override
  Future<List<TeamMember>> getTeamMembers() async => teamMembers;

  @override
  Future<List<KpiMetric>> getKpis() async => kpiData;

  @override
  Future<List<AlertItem>> getAlerts() async => alerts;

  @override
  Future<List<ModuleProgress>> getModuleProgress({
    int companyId = 1,
  }) async {
    return moduleProgressItems;
  }

  @override
  Future<List<RankingTeam>> getRanking() async => rankingData;

  @override
  Future<List<MarketSegment>> getMarketSegments() async => marketSegments;

  @override
  Future<List<Competitor>> getCompetitors() async => competitors;

  @override
  Future<List<ScenarioData>> getFinancialScenarios() async {
    return financialScenarios;
  }

  @override
  Future<List<CashFlowEntry>> getCashFlow() async => cashFlowEntries;

  @override
  Future<List<Inefficiency>> getOrganizationalInefficiencies() async {
    return organizationalInefficiencies;
  }

  @override
  Future<List<AdminTeamStatus>> getAdminTeams() async => adminTeams;
}
