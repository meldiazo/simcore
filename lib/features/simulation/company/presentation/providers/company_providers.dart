import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/simulation/company/data/datasources/company_remote_datasource.dart';
import 'package:simcore_frontend/features/simulation/company/data/repositories/company_repository_impl.dart';
import 'package:simcore_frontend/features/simulation/company/domain/entities/company.dart';
import 'package:simcore_frontend/features/simulation/company/domain/entities/module_progress.dart';
import 'package:simcore_frontend/features/simulation/company/domain/repositories/company_repository.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────

final companyRemoteDataSourceProvider =
    Provider<CompanyRemoteDataSource>((ref) {
  return CompanyRemoteDataSource(ref.watch(simulationApiClientProvider));
});

final companyRepositoryProvider = Provider<CompanyRepository>((ref) {
  return CompanyRepositoryImpl(ref.watch(companyRemoteDataSourceProvider));
});

// ── Workspace data ────────────────────────────────────────────────────────────

final companyDetailProvider = FutureProvider<Company>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(const _NoCompany());
  return ref
      .watch(companyRepositoryProvider)
      .getCompanyById(companyId: ctx.companyId);
});

final companyModuleProgressProvider =
    FutureProvider<List<CompanyModuleProgress>>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(const []);
  return ref
      .watch(companyRepositoryProvider)
      .getModuleProgress(companyId: ctx.companyId);
});

final activeScenarioProvider =
    FutureProvider<Map<String, dynamic>?>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(null);
  return ref
      .watch(companyRepositoryProvider)
      .getActiveScenario(groupId: ctx.groupId);
});

final companyIncoherencesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(const []);
  return ref.watch(companyRepositoryProvider).getIncoherences(
        companyId: ctx.companyId,
        scenarioType: 'PROBABLE',
      );
});

final companyDecisionsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(const []);
  return ref
      .watch(companyRepositoryProvider)
      .getDecisions(companyId: ctx.companyId);
});

// ── Workspace aggregate ───────────────────────────────────────────────────────

class CompanyWorkspaceData {
  const CompanyWorkspaceData({
    required this.company,
    required this.modules,
    required this.activeScenario,
    required this.incoherences,
    required this.decisions,
  });

  final Company company;
  final List<CompanyModuleProgress> modules;
  final Map<String, dynamic>? activeScenario;
  final List<Map<String, dynamic>> incoherences;
  final List<Map<String, dynamic>> decisions;

  int get completedModules =>
      modules.where((m) => m.status.isComplete).length;
}

final companyWorkspaceProvider =
    FutureProvider<CompanyWorkspaceData>((ref) async {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) {
    throw StateError('SimulationContext no inicializado.');
  }

  final repo = ref.watch(companyRepositoryProvider);

  final results = await Future.wait([
    repo.getCompanyById(companyId: ctx.companyId),
    repo.getModuleProgress(companyId: ctx.companyId),
    repo.getActiveScenario(groupId: ctx.groupId),
    repo.getIncoherences(companyId: ctx.companyId, scenarioType: 'PROBABLE'),
    repo.getDecisions(companyId: ctx.companyId),
  ]);

  return CompanyWorkspaceData(
    company: results[0] as Company,
    modules: results[1] as List<CompanyModuleProgress>,
    activeScenario: results[2] as Map<String, dynamic>?,
    incoherences: results[3] as List<Map<String, dynamic>>,
    decisions: results[4] as List<Map<String, dynamic>>,
  );
});

// Placeholder para cuando el contexto aún no está listo
class _NoCompany implements Company {
  const _NoCompany();

  @override
  int get id => 0;
  @override
  String get name => '';
  @override
  int get groupId => 0;
  @override
  CompanyStatus get status => CompanyStatus.inSimulation;

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => false;
}
