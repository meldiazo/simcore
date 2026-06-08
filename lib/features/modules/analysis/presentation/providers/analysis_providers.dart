import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/modules/analysis/data/datasources/analysis_remote_datasource.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

final analysisRemoteDataSourceProvider = Provider<AnalysisRemoteDataSource>((ref) {
  return AnalysisRemoteDataSource(ref.watch(simulationApiClientProvider));
});

final financialIndicatorsProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(null);
  return ref
      .watch(analysisRemoteDataSourceProvider)
      .getFinancialIndicators(companyId: ctx.companyId);
});

final analysisIncoherencesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(const []);
  return ref
      .watch(analysisRemoteDataSourceProvider)
      .getIncoherences(companyId: ctx.companyId);
});

final narrativeReportProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(null);
  return ref
      .watch(analysisRemoteDataSourceProvider)
      .getNarrativeReport(companyId: ctx.companyId);
});

class AnalysisNotifier extends StateNotifier<AsyncValue<void>> {
  AnalysisNotifier(this._ds, this._ref) : super(const AsyncValue.data(null));

  final AnalysisRemoteDataSource _ds;
  final Ref _ref;

  int get _companyId =>
      _ref.read(simulationContextNotifierProvider).context?.companyId ?? 0;

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

final analysisNotifierProvider =
    StateNotifierProvider.autoDispose<AnalysisNotifier, AsyncValue<void>>(
  (ref) => AnalysisNotifier(
    ref.watch(analysisRemoteDataSourceProvider),
    ref,
  ),
);
