import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/modules/accounting/data/datasources/accounting_remote_datasource.dart';
import 'package:simcore_frontend/features/modules/accounting/data/models/accounting_entry_model.dart';
import 'package:simcore_frontend/features/modules/accounting/data/models/financial_statement_model.dart';
import 'package:simcore_frontend/features/modules/accounting/data/repositories/accounting_repository_impl.dart';
import 'package:simcore_frontend/features/simulation/company/presentation/providers/company_providers.dart';
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
  return repository.getAccountingEntries(companyId);
});

final financialStatementsProvider =
    FutureProvider.family<List<FinancialStatementModel>, String>(
        (ref, companyId) async {
  final repository = ref.watch(accountingRepositoryProvider);
  return repository.getFinancialStatements(companyId);
});

final accountingActionsProvider = Provider((ref) => AccountingActions(ref));

class AccountingActions {
  AccountingActions(this.ref);

  final Ref ref;

  Future<void> generateEntries(String companyId) async {
    final repository = ref.read(accountingRepositoryProvider);
    await repository.generateAccountingEntries(companyId);

    ref.invalidate(accountingEntriesProvider(companyId));
  }

  Future<void> generateStatements(String companyId) async {
    final repository = ref.read(accountingRepositoryProvider);
    await repository.generateFinancialStatements(companyId);

    ref.invalidate(financialStatementsProvider(companyId));
  }

  Future<void> completeModule(String companyId) async {
    final repository = ref.read(accountingRepositoryProvider);
    final parsedCompanyId = int.tryParse(companyId);

    if (parsedCompanyId != null) {
      final companyRepository = ref.read(companyRepositoryProvider);
      final progress = await companyRepository.getModuleProgress(
        companyId: parsedCompanyId,
      );
      final accountingProgress = progress
          .where((module) => module.module == SimModule.accounting)
          .firstOrNull;

      if (accountingProgress?.status == ModuleStatus.complete) {
        ref.invalidate(companyModuleProgressProvider);
        ref.invalidate(global_providers.moduleProgressProvider);
        return;
      }
    }

    await repository.startAccountingModule(companyId);
    await repository.completeAccountingModule(companyId);

    ref.invalidate(companyModuleProgressProvider);
    ref.invalidate(global_providers.moduleProgressProvider);
  }
}
