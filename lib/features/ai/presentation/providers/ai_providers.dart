import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/ai/data/datasources/ai_remote_datasource.dart';
import 'package:simcore_frontend/features/ai/data/models/ai_suggestion_model.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

final aiRemoteDataSourceProvider = Provider<AiRemoteDataSource>((ref) {
  return AiRemoteDataSource(ref.watch(simulationApiClientProvider));
});

final marketValidationAiProvider = FutureProvider<AiSuggestionModel?>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(null);
  return ref
      .watch(aiRemoteDataSourceProvider)
      .validateMarket(companyId: ctx.companyId);
});

final ratioExplanationAiProvider = FutureProvider<AiSuggestionModel?>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(null);
  return ref
      .watch(aiRemoteDataSourceProvider)
      .explainRatios(companyId: ctx.companyId);
});

final defenseQuestionsAiProvider = FutureProvider<AiSuggestionModel?>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(null);
  return ref
      .watch(aiRemoteDataSourceProvider)
      .defenseQuestions(companyId: ctx.companyId);
});

final narrativeAiProvider = FutureProvider<AiSuggestionModel?>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(null);
  return ref
      .watch(aiRemoteDataSourceProvider)
      .narrative(companyId: ctx.companyId);
});
