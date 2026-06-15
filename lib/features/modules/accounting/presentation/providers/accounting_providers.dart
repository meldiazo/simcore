import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/modules/accounting/data/datasources/accounting_remote_datasource.dart';
import 'package:simcore_frontend/features/modules/accounting/data/models/accounting_entry_model.dart';
import 'package:simcore_frontend/features/modules/accounting/data/models/financial_statement_model.dart';
import 'package:simcore_frontend/features/modules/accounting/data/repositories/accounting_repository_impl.dart';
import 'package:simcore_frontend/features/simulation/company/presentation/providers/company_providers.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/scenario_context_provider.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_providers.dart'
    as global_providers;

final accountingRemoteDataSourceProvider =
    Provider<AccountingRemoteDataSource>((ref) {
  return AccountingRemoteDataSourceImpl(
    apiClient: ref.watch(simulationApiClientProvider),
  );
});

final accountingRepositoryProvider = Provider<AccountingRepository>((ref) {
  final dataSource = ref.watch(accountingRemoteDataSourceProvider);
  return AccountingRepositoryImpl(remoteDataSource: dataSource);
});

final accountingEntriesProvider =
    FutureProvider.family<List<AccountingEntryModel>, String>(
        (ref, companyId) async {
  final repository = ref.watch(accountingRepositoryProvider);
  final scenarioType = ref.watch(selectedScenarioTypeProvider);
  return repository.getAccountingEntries(companyId, scenarioType);
});

final financialStatementsProvider =
    FutureProvider.family<List<FinancialStatementModel>, String>(
        (ref, companyId) async {
  final repository = ref.watch(accountingRepositoryProvider);
  final scenarioType = ref.watch(selectedScenarioTypeProvider);
  return repository.getFinancialStatements(companyId, scenarioType);
});

final accountingActionsProvider = Provider((ref) => AccountingActions(ref));

class AccountingActions {
  AccountingActions(this.ref);

  final Ref ref;

  Future<void> generateEntries(String companyId) async {
    final repository = ref.read(accountingRepositoryProvider);
    final scenarioType = ref.read(selectedScenarioTypeProvider);
    await repository.generateAccountingEntries(companyId, scenarioType);

    ref.invalidate(accountingEntriesProvider(companyId));
  }

  Future<void> generateStatements(String companyId) async {
    final repository = ref.read(accountingRepositoryProvider);
    final scenarioType = ref.read(selectedScenarioTypeProvider);
    await repository.generateFinancialStatements(companyId, scenarioType);

    ref.invalidate(financialStatementsProvider(companyId));
  }

  Future<void> completeModule(String companyId) async {
    final repository = ref.read(accountingRepositoryProvider);
    final statements =
        await ref.read(financialStatementsProvider(companyId).future);
    final hasOutdated = statements.any(
      (statement) => statement.status.trim().toUpperCase() == 'OUTDATED',
    );

    if (statements.isEmpty || hasOutdated) {
      throw StateError(
        'No se puede completar Contabilidad con estados financieros vacios u OUTDATED.',
      );
    }

    await repository.completeAccountingModule(companyId);

    ref.invalidate(companyModuleProgressProvider);
    ref.invalidate(global_providers.moduleProgressProvider);
  }
}
