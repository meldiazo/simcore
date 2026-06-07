import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart'; 
import '../../data/datasources/accounting_remote_datasource.dart';
import '../../data/repositories/accounting_repository_impl.dart';
import '../../data/models/accounting_entry_model.dart';
import '../../data/models/financial_statement_model.dart';

final accountingRepositoryProvider = Provider<AccountingRepository>((ref) {
  final dio = Dio(); 
  final dataSource = AccountingRemoteDataSourceImpl(client: dio);
  return AccountingRepositoryImpl(remoteDataSource: dataSource);
});

final accountingEntriesProvider = FutureProvider.family<List<AccountingEntryModel>, String>((ref, companyId) async {
  final repository = ref.read(accountingRepositoryProvider);
  return repository.getAccountingEntries(companyId);
});

final financialStatementsProvider = FutureProvider.family<List<FinancialStatementModel>, String>((ref, companyId) async {
  final repository = ref.read(accountingRepositoryProvider);
  return repository.getFinancialStatements(companyId);
});

final accountingActionsProvider = Provider((ref) => AccountingActions(ref));

class AccountingActions {
  final Ref ref;
  AccountingActions(this.ref);

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
    await repository.completeAccountingModule(companyId);
  }
}