import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/modules/analysis/data/datasources/analysis_remote_datasource.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/scenario_context_provider.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

final analysisRemoteDataSourceProvider =
    Provider<AnalysisRemoteDataSource>((ref) {
  return AnalysisRemoteDataSource(ref.watch(simulationApiClientProvider));
});

final consolidatedAnalysisProvider =
    FutureProvider<Map<String, dynamic>?>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(null);
  final scenarioType = ref.watch(selectedScenarioTypeProvider);
  return ref
      .watch(analysisRemoteDataSourceProvider)
      .getAnalysis(companyId: ctx.companyId, scenarioType: scenarioType);
});

final financialIndicatorsProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  final analysis = await ref.watch(consolidatedAnalysisProvider.future);
  if (analysis == null) return null;
  return _readMap(analysis, const [
    'financialIndicators',
    'indicators',
    'kpis',
  ]);
});

final analysisIncoherencesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final analysis = await ref.watch(consolidatedAnalysisProvider.future);
  if (analysis == null) return const [];
  return _readList(analysis, const [
    'incoherences',
    'warnings',
    'alerts',
  ]);
});

final narrativeReportProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  final analysis = await ref.watch(consolidatedAnalysisProvider.future);
  if (analysis == null) return null;
  return _readMap(analysis, const [
    'narrativeReport',
    'report',
    'narrative',
  ]);
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

Map<String, dynamic>? _readMap(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return null;
}

List<Map<String, dynamic>> _readList(
  Map<String, dynamic> source,
  List<String> keys,
) {
  for (final key in keys) {
    final value = source[key];
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
  }
  return const [];
}
