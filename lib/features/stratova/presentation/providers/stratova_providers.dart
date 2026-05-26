import 'package:core_sim_ia/core/config/app_config.dart';
import 'package:core_sim_ia/core/network/api_client_providers.dart';
import 'package:core_sim_ia/features/shared/data/demo/simcore_demo_data.dart';
import 'package:core_sim_ia/features/stratova/data/datasources/stratova_data_source.dart';
import 'package:core_sim_ia/features/stratova/data/datasources/stratova_mock_data_source.dart';
import 'package:core_sim_ia/features/stratova/data/datasources/stratova_remote_data_source.dart';
import 'package:core_sim_ia/features/stratova/data/repositories/stratova_repository_impl.dart';
import 'package:core_sim_ia/features/stratova/domain/repositories/stratova_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



final stratovaDataSourceProvider = Provider<StratovaDataSource>((ref) {
  final config = ref.watch(appConfigProvider);

  if (config.useMockData) {
    return StratovaMockDataSource();
  }

  return StratovaRemoteDataSource(
  ref.watch(simulationApiClientProvider),
);
});

final stratovaRepositoryProvider = Provider<StratovaRepository>((ref) {
  return StratovaRepositoryImpl(
    ref.watch(stratovaDataSourceProvider),
  );
});

final currentUserProvider = FutureProvider<StudentUser>((ref) {
  return ref.watch(stratovaRepositoryProvider).getCurrentUser();
});

final currentCycleProvider = FutureProvider<CurrentCycle>((ref) {
  return ref.watch(stratovaRepositoryProvider).getCurrentCycle();
});

final teamMembersProvider = FutureProvider<List<TeamMember>>((ref) {
  return ref.watch(stratovaRepositoryProvider).getTeamMembers();
});

final kpisProvider = FutureProvider<List<KpiMetric>>((ref) {
  return ref.watch(stratovaRepositoryProvider).getKpis();
});

final alertsProvider = FutureProvider<List<AlertItem>>((ref) {
  return ref.watch(stratovaRepositoryProvider).getAlerts();
});

final decisionModulesProvider = FutureProvider<List<DecisionModule>>((ref) {
  return ref.watch(stratovaRepositoryProvider).getDecisionModules();
});

final rankingProvider = FutureProvider<List<RankingTeam>>((ref) {
  return ref.watch(stratovaRepositoryProvider).getRanking();
});

final marketSegmentsProvider = FutureProvider<List<MarketSegment>>((ref) {
  return ref.watch(stratovaRepositoryProvider).getMarketSegments();
});

final competitorsProvider = FutureProvider<List<Competitor>>((ref) {
  return ref.watch(stratovaRepositoryProvider).getCompetitors();
});

final financialScenariosProvider = FutureProvider<List<ScenarioData>>((ref) {
  return ref.watch(stratovaRepositoryProvider).getFinancialScenarios();
});

final cashFlowProvider = FutureProvider<List<CashFlowEntry>>((ref) {
  return ref.watch(stratovaRepositoryProvider).getCashFlow();
});

final organizationalInefficienciesProvider =
    FutureProvider<List<Inefficiency>>((ref) {
  return ref
      .watch(stratovaRepositoryProvider)
      .getOrganizationalInefficiencies();
});

final adminTeamsProvider = FutureProvider<List<AdminTeamStatus>>((ref) {
  return ref.watch(stratovaRepositoryProvider).getAdminTeams();
});
