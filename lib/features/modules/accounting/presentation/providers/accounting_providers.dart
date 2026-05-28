import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/modules/accounting/data/datasources/accounting_remote_datasource.dart';
import 'package:simcore_frontend/features/modules/accounting/domain/entities/accounting_entry.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

final accountingRemoteDataSourceProvider = Provider<AccountingRemoteDataSource>((ref) {
  return AccountingRemoteDataSource(ref.watch(simulationApiClientProvider));
});

final accountingEntriesProvider = FutureProvider<List<AccountingEntry>>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(const []);
  return ref
      .watch(accountingRemoteDataSourceProvider)
      .getEntries(companyId: ctx.companyId);
});

final financialStatementsProvider = FutureProvider<List<FinancialStatement>>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(const []);
  return ref
      .watch(accountingRemoteDataSourceProvider)
      .getStatements(companyId: ctx.companyId);
});

class AccountingNotifier extends StateNotifier<AsyncValue<void>> {
  AccountingNotifier(this._ds, this._ref) : super(const AsyncValue.data(null));

  final AccountingRemoteDataSource _ds;
  final Ref _ref;

  int get _companyId =>
      _ref.read(simulationContextNotifierProvider).context?.companyId ?? 0;

  Future<void> generateEntries() async {
    state = const AsyncValue.loading();
    try {
      await _ds.generateEntries(companyId: _companyId);
      _ref.invalidate(accountingEntriesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> generateStatements() async {
    state = const AsyncValue.loading();
    try {
      await _ds.generateStatements(companyId: _companyId);
      _ref.invalidate(financialStatementsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completeModule() async {
    state = const AsyncValue.loading();
    try {
      await _ds.completeModule(companyId: _companyId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final accountingNotifierProvider =
    StateNotifierProvider.autoDispose<AccountingNotifier, AsyncValue<void>>(
  (ref) => AccountingNotifier(
    ref.watch(accountingRemoteDataSourceProvider),
    ref,
  ),
);
