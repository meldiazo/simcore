import 'package:simcore_frontend/core/config/app_config.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/shared/data/demo/simcore_demo_data.dart';
import 'package:simcore_frontend/features/simulation/shared/data/datasources/simulation_data_source.dart';
import 'package:simcore_frontend/features/simulation/shared/data/datasources/simulation_mock_data_source.dart';
import 'package:simcore_frontend/features/simulation/shared/data/datasources/simulation_remote_data_source.dart';
import 'package:simcore_frontend/features/simulation/shared/data/repositories/simulation_repository_impl.dart';
import 'package:simcore_frontend/features/simulation/shared/domain/repositories/simulation_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final SimulationDataSourceProvider = Provider<SimulationDataSource>((ref) {
  final config = ref.watch(appConfigProvider);

  if (config.useMockData) {
    return SimulationMockDataSource();
  }

  return SimulationRemoteDataSource(
    ref.watch(simulationApiClientProvider),
  );
});

final SimulationRepositoryProvider = Provider<SimulationRepository>((ref) {
  return SimulationRepositoryImpl(
    ref.watch(SimulationDataSourceProvider),
  );
});

final currentUserProvider = FutureProvider<StudentUser>((ref) {
  return ref.watch(SimulationRepositoryProvider).getCurrentUser();
});

final currentCycleProvider = FutureProvider<CurrentCycle>((ref) {
  return ref.watch(SimulationRepositoryProvider).getCurrentCycle();
});

final teamMembersProvider = FutureProvider<List<TeamMember>>((ref) {
  return ref.watch(SimulationRepositoryProvider).getTeamMembers();
});

final kpisProvider = FutureProvider<List<KpiMetric>>((ref) {
  return ref.watch(SimulationRepositoryProvider).getKpis();
});

final alertsProvider = FutureProvider<List<AlertItem>>((ref) {
  return ref.watch(SimulationRepositoryProvider).getAlerts();
});

final decisionModulesProvider = FutureProvider<List<DecisionModule>>((ref) {
  return ref.watch(SimulationRepositoryProvider).getDecisionModules();
});

final rankingProvider = FutureProvider<List<RankingTeam>>((ref) {
  return ref.watch(SimulationRepositoryProvider).getRanking();
});

final marketSegmentsProvider = FutureProvider<List<MarketSegment>>((ref) {
  return ref.watch(SimulationRepositoryProvider).getMarketSegments();
});

final competitorsProvider = FutureProvider<List<Competitor>>((ref) {
  return ref.watch(SimulationRepositoryProvider).getCompetitors();
});

final financialScenariosProvider = FutureProvider<List<ScenarioData>>((ref) {
  return ref.watch(SimulationRepositoryProvider).getFinancialScenarios();
});

final cashFlowProvider = FutureProvider<List<CashFlowEntry>>((ref) {
  return ref.watch(SimulationRepositoryProvider).getCashFlow();
});

final organizationalInefficienciesProvider =
    FutureProvider<List<Inefficiency>>((ref) {
  return ref
      .watch(SimulationRepositoryProvider)
      .getOrganizationalInefficiencies();
});

final adminTeamsProvider = FutureProvider<List<AdminTeamStatus>>((ref) {
  return ref.watch(SimulationRepositoryProvider).getAdminTeams();
});
