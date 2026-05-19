import 'package:core_sim_ia/features/shared/data/demo/simcore_demo_data.dart';
import 'package:core_sim_ia/features/stratova/data/datasources/stratova_data_source.dart';
import 'package:core_sim_ia/features/stratova/domain/repositories/stratova_repository.dart';

class StratovaRepositoryImpl implements StratovaRepository {
  StratovaRepositoryImpl(this._dataSource);

  final StratovaDataSource _dataSource;

  @override
  Future<StudentUser> getCurrentUser() {
    return _dataSource.getCurrentUser();
  }

  @override
  Future<CurrentCycle> getCurrentCycle() {
    return _dataSource.getCurrentCycle();
  }

  @override
  Future<List<TeamMember>> getTeamMembers() {
    return _dataSource.getTeamMembers();
  }

  @override
  Future<List<KpiMetric>> getKpis() {
    return _dataSource.getKpis();
  }

  @override
  Future<List<AlertItem>> getAlerts() {
    return _dataSource.getAlerts();
  }

  @override
  Future<List<DecisionModule>> getDecisionModules({
    int companyId = 1,
  }) {
    return _dataSource.getDecisionModules(companyId: companyId);
  }

  @override
  Future<List<RankingTeam>> getRanking() {
    return _dataSource.getRanking();
  }

  @override
  Future<List<MarketSegment>> getMarketSegments() {
    return _dataSource.getMarketSegments();
  }

  @override
  Future<List<Competitor>> getCompetitors() {
    return _dataSource.getCompetitors();
  }

  @override
  Future<List<ScenarioData>> getFinancialScenarios() {
    return _dataSource.getFinancialScenarios();
  }

  @override
  Future<List<CashFlowEntry>> getCashFlow() {
    return _dataSource.getCashFlow();
  }

  @override
  Future<List<Inefficiency>> getOrganizationalInefficiencies() {
    return _dataSource.getOrganizationalInefficiencies();
  }

  @override
  Future<List<AdminTeamStatus>> getAdminTeams() {
    return _dataSource.getAdminTeams();
  }
}
