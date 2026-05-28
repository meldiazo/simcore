import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/modules/investment_financing/data/datasources/investment_financing_remote_datasource.dart';
import 'package:simcore_frontend/features/modules/investment_financing/domain/entities/financing_option.dart';
import 'package:simcore_frontend/features/modules/investment_financing/domain/entities/investment_item.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

final investmentFinancingRemoteDataSourceProvider =
    Provider<InvestmentFinancingRemoteDataSource>((ref) {
  return InvestmentFinancingRemoteDataSource(ref.watch(simulationApiClientProvider));
});

final investmentSummaryProvider = FutureProvider<InvestmentSummary>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) {
    return Future.value(InvestmentSummary(
      companyId: 0,
      items: const [],
      totalFixedAssets: 0,
      totalWorkingCapital: 0,
      totalPreOperative: 0,
      grandTotal: 0,
      hasMinimumData: false,
    ));
  }
  return ref
      .watch(investmentFinancingRemoteDataSourceProvider)
      .getInvestmentSummary(companyId: ctx.companyId);
});

final financingSummaryProvider = FutureProvider<FinancingSummary>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) {
    return Future.value(FinancingSummary(
      companyId: 0,
      options: const [],
      totalPrincipal: 0,
      hasMinimumData: false,
      hasSelectedOption: false,
    ));
  }
  return ref
      .watch(investmentFinancingRemoteDataSourceProvider)
      .getFinancingSummary(companyId: ctx.companyId);
});

class InvestmentFinancingNotifier extends StateNotifier<AsyncValue<void>> {
  InvestmentFinancingNotifier(this._ds, this._ref) : super(const AsyncValue.data(null));

  final InvestmentFinancingRemoteDataSource _ds;
  final Ref _ref;

  int get _companyId =>
      _ref.read(simulationContextNotifierProvider).context?.companyId ?? 0;

  Future<void> createInvestmentItem(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _ds.createInvestmentItem(companyId: _companyId, data: data);
      _ref.invalidate(investmentSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateInvestmentItem(int itemId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _ds.updateInvestmentItem(companyId: _companyId, itemId: itemId, data: data);
      _ref.invalidate(investmentSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteInvestmentItem(int itemId) async {
    state = const AsyncValue.loading();
    try {
      await _ds.deleteInvestmentItem(companyId: _companyId, itemId: itemId);
      _ref.invalidate(investmentSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completeInvestment() async {
    state = const AsyncValue.loading();
    try {
      await _ds.completeInvestment(companyId: _companyId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createFinancingOption(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _ds.createFinancingOption(companyId: _companyId, data: data);
      _ref.invalidate(financingSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateFinancingOption(int optionId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _ds.updateFinancingOption(companyId: _companyId, optionId: optionId, data: data);
      _ref.invalidate(financingSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteFinancingOption(int optionId) async {
    state = const AsyncValue.loading();
    try {
      await _ds.deleteFinancingOption(companyId: _companyId, optionId: optionId);
      _ref.invalidate(financingSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> selectFinancingOption(int optionId) async {
    state = const AsyncValue.loading();
    try {
      await _ds.selectFinancingOption(companyId: _companyId, optionId: optionId);
      _ref.invalidate(financingSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completeFinancing() async {
    state = const AsyncValue.loading();
    try {
      await _ds.completeFinancing(companyId: _companyId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final investmentFinancingNotifierProvider =
    StateNotifierProvider.autoDispose<InvestmentFinancingNotifier, AsyncValue<void>>(
  (ref) => InvestmentFinancingNotifier(
    ref.watch(investmentFinancingRemoteDataSourceProvider),
    ref,
  ),
);
