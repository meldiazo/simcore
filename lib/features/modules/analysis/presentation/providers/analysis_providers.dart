import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/ai/data/models/ai_suggestion_model.dart';
import 'package:simcore_frontend/features/modules/analysis/data/datasources/analysis_remote_datasource.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';
import 'package:simcore_frontend/features/simulation/company/presentation/providers/company_providers.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_providers.dart' as global_providers;

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
      
      _ref.invalidate(companyModuleProgressProvider);
      _ref.invalidate(global_providers.moduleProgressProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
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

final incrementalAnalysisProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(null);
  return ref
      .watch(analysisRemoteDataSourceProvider)
      .getIncrementalAnalysis(companyId: ctx.companyId);
});

class SaveIncrementalNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  SaveIncrementalNotifier(this._ds, this._ref) : super(const AsyncValue.data(null));
  final AnalysisRemoteDataSource _ds;
  final Ref _ref;

  Future<bool> save(Map<String, dynamic> body) async {
    final ctx = _ref.read(simulationContextNotifierProvider).context;
    if (ctx == null) return false;
    state = const AsyncValue.loading();
    try {
      final res = await _ds.saveIncrementalAnalysis(companyId: ctx.companyId, body: body);
      state = AsyncValue.data(res);
      _ref.invalidate(incrementalAnalysisProvider);
      _ref.invalidate(financialIndicatorsProvider);
      _ref.invalidate(companyWorkspaceProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final saveIncrementalNotifierProvider =
    StateNotifierProvider.autoDispose<SaveIncrementalNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return SaveIncrementalNotifier(ref.watch(analysisRemoteDataSourceProvider), ref);
});

final aiViabilityProvider = FutureProvider<AiSuggestionModel?>((ref) async {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return null;
  final map = await ref.watch(analysisRemoteDataSourceProvider).getAiViability(companyId: ctx.companyId);
  return map != null ? AiSuggestionModel.fromJson(map) : null;
});

final aiAdoptionProvider = FutureProvider.family<AiSuggestionModel?, ({double price, double budget, String channel})>((ref, args) async {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return null;
  final map = await ref.watch(analysisRemoteDataSourceProvider).getAiAdoption(
    companyId: ctx.companyId,
    price: args.price,
    marketingBudget: args.budget,
    channel: args.channel,
  );
  return map != null ? AiSuggestionModel.fromJson(map) : null;
});

final aiStressTestProvider = FutureProvider.family<AiSuggestionModel?, double>((ref, van) async {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return null;
  final map = await ref.watch(analysisRemoteDataSourceProvider).getAiStressTest(
    companyId: ctx.companyId,
    vanEstimado: van,
  );
  return map != null ? AiSuggestionModel.fromJson(map) : null;
});
