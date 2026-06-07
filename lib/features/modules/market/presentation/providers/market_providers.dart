import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/modules/market/data/datasources/market_remote_datasource.dart';
import 'package:simcore_frontend/features/modules/market/domain/entities/market_assumption.dart';
import 'package:simcore_frontend/features/modules/market/domain/entities/sales_projection.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

final marketRemoteDataSourceProvider = Provider<MarketRemoteDataSource>((ref) {
  return MarketRemoteDataSource(ref.watch(simulationApiClientProvider));
});

final marketAssumptionProvider = FutureProvider<MarketAssumption?>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(null);
  return ref.watch(marketRemoteDataSourceProvider).getAssumption(companyId: ctx.companyId);
});

final salesProjectionProvider = FutureProvider<SalesProjection?>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(null);
  return ref.watch(marketRemoteDataSourceProvider).getProjection(companyId: ctx.companyId);
});

class MarketNotifier extends StateNotifier<AsyncValue<void>> {
  MarketNotifier(this._ds, this._ref) : super(const AsyncValue.data(null));

  final MarketRemoteDataSource _ds;
  final Ref _ref;

  int get _companyId =>
      _ref.read(simulationContextNotifierProvider).context?.companyId ?? 0;

  Future<void> saveAssumption(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _ds.saveAssumption(companyId: _companyId, data: data);
      _ref.invalidate(marketAssumptionProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> generateProjection() async {
    state = const AsyncValue.loading();
    try {
      await _ds.generateProjection(companyId: _companyId);
      _ref.invalidate(salesProjectionProvider);
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

final marketNotifierProvider =
    StateNotifierProvider.autoDispose<MarketNotifier, AsyncValue<void>>(
  (ref) => MarketNotifier(ref.watch(marketRemoteDataSourceProvider), ref),
);
