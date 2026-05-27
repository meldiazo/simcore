import 'package:simcore_frontend/core/config/app_config.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/shared/data/demo/simcore_demo_data.dart';
import 'package:simcore_frontend/features/simulation/shared/data/datasources/simulation_data_source.dart';
import 'package:simcore_frontend/features/simulation/shared/data/datasources/simulation_mock_data_source.dart';
import 'package:simcore_frontend/features/simulation/shared/data/datasources/simulation_remote_data_source.dart';
import 'package:simcore_frontend/features/simulation/shared/data/repositories/simulation_repository_impl.dart';
import 'package:simcore_frontend/features/simulation/shared/domain/repositories/simulation_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

final simulationDataSourceProvider = Provider<SimulationDataSource>((ref) {
  final config = ref.watch(appConfigProvider);

  if (config.useMockData) {
    return SimulationMockDataSource();
  }

  return SimulationRemoteDataSource(
    ref.watch(simulationApiClientProvider),
  );
});

final simulationRepositoryProvider = Provider<SimulationRepository>((ref) {
  return SimulationRepositoryImpl(
    ref.watch(simulationDataSourceProvider),
  );
});

final currentUserProvider = FutureProvider<StudentUser>((ref) {
  return ref.watch(simulationRepositoryProvider).getCurrentUser();
});

final currentCycleProvider = FutureProvider<CurrentCycle>((ref) {
  return ref.watch(simulationRepositoryProvider).getCurrentCycle();
});

final teamMembersProvider = FutureProvider<List<TeamMember>>((ref) {
  return ref.watch(simulationRepositoryProvider).getTeamMembers();
});

final kpisProvider = FutureProvider<List<KpiMetric>>((ref) {
  return ref.watch(simulationRepositoryProvider).getKpis();
});

final alertsProvider = FutureProvider<List<AlertItem>>((ref) {
  return ref.watch(simulationRepositoryProvider).getAlerts();
});

final moduleProgressProvider = FutureProvider<List<ModuleProgress>>((ref) {
  final contextState = ref.watch(simulationContextNotifierProvider);
  final context = contextState.context;

  if (context == null) {
    // Contexto aún no inicializado: retornar lista vacía sin error.
    return Future.value(const <ModuleProgress>[]);
  }

  return ref
      .watch(simulationRepositoryProvider)
      .getModuleProgress(companyId: context.companyId);
});

final rankingProvider = FutureProvider<List<RankingTeam>>((ref) {
  return ref.watch(simulationRepositoryProvider).getRanking();
});

final marketSegmentsProvider = FutureProvider<List<MarketSegment>>((ref) {
  return ref.watch(simulationRepositoryProvider).getMarketSegments();
});

final competitorsProvider = FutureProvider<List<Competitor>>((ref) {
  return ref.watch(simulationRepositoryProvider).getCompetitors();
});

final financialScenariosProvider = FutureProvider<List<ScenarioData>>((ref) {
  return ref.watch(simulationRepositoryProvider).getFinancialScenarios();
});

final cashFlowProvider = FutureProvider<List<CashFlowEntry>>((ref) {
  return ref.watch(simulationRepositoryProvider).getCashFlow();
});

final organizationalInefficienciesProvider =
    FutureProvider<List<Inefficiency>>((ref) {
  return ref
      .watch(simulationRepositoryProvider)
      .getOrganizationalInefficiencies();
});

final adminTeamsProvider = FutureProvider<List<AdminTeamStatus>>((ref) {
  return ref.watch(simulationRepositoryProvider).getAdminTeams();
});
