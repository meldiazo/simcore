import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/auth/presentation/providers/auth_notifier.dart';

import '../../data/datasources/company_remote_datasource.dart';
import '../../data/repositories/company_repository_impl.dart';
import '../../domain/repositories/company_repository.dart';
import '../../domain/entities/company.dart';
import '../../domain/entities/module_progress.dart';

class WorkspaceData {
  final Company company;
  final SimulationScenario scenario;
  final List<ModuleProgress> modules;
  final List<Incoherence> incoherences;
  final List<DecisionLog> decisions;

  WorkspaceData({
    required this.company,
    required this.scenario,
    required this.modules,
    required this.incoherences,
    required this.decisions,
  });
}

final companyRemoteDataSourceProvider = Provider<CompanyRemoteDataSource>((ref) {
  final client = ref.watch(simulationApiClientProvider);
  return CompanyRemoteDataSource(client as dynamic);
});

final companyRepositoryProvider = Provider<CompanyRepository>((ref) {
  return CompanyRepositoryImpl(ref.watch(companyRemoteDataSourceProvider));
});

final companyWorkspaceProvider = FutureProvider.autoDispose<WorkspaceData>((ref) async {
  final repo = ref.watch(companyRepositoryProvider);
  final authState = ref.watch(authNotifierProvider);
  final user = authState.user;
  
  if (user == null) {
    throw Exception('Sesión expirada o usuario no autenticado. Por favor, vuelva a iniciar sesión.');
  }

  // CONTROL ARQUITECTÓNICO SANITIZADO: Parseo de seguridad para asegurar la compatibilidad con int
  final int companyId = int.tryParse(user.tenantId.toString()) ?? 0;
  final int groupId = int.tryParse(user.tenantId.toString()) ?? 0;

  // MANDAMIENTO 18: Concurrencia real para evitar retrasos cognitivos en el flujo (Mesa de Integración)
  final dataFutures = await Future.wait([
    repo.getCompany(companyId),
    repo.getActiveScenario(groupId),
    repo.getModules(companyId),
    repo.getIncoherences(companyId),
    repo.getDecisions(companyId),
  ]);

  return WorkspaceData(
    company: dataFutures[0] as Company,
    scenario: dataFutures[1] as SimulationScenario,
    modules: dataFutures[2] as List<ModuleProgress>,
    incoherences: dataFutures[3] as List<Incoherence>,
    decisions: dataFutures[4] as List<DecisionLog>,
  );
});