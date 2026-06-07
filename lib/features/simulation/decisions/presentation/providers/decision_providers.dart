import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/datasources/decision_remote_datasource.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/models/decision_model.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

final decisionRemoteDataSourceProvider = Provider<DecisionRemoteDataSource>((ref) {
  return DecisionRemoteDataSource(ref.watch(simulationApiClientProvider));
});

final companyDecisionsProvider = FutureProvider<List<DecisionModel>>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(const []);
  return ref
      .watch(decisionRemoteDataSourceProvider)
      .getDecisionsByCompany(companyId: ctx.companyId);
});

class DecisionFormNotifier extends StateNotifier<AsyncValue<DecisionModel?>> {
  DecisionFormNotifier(this._ds) : super(const AsyncValue.data(null));
  final DecisionRemoteDataSource _ds;

  Future<DecisionModel?> createDecision({
    required int companyId,
    required String module,
    required String decisionType,
    required String payload,
    required String justification,
  }) async {
    state = const AsyncValue.loading();
    try {
      final decision = await _ds.createDecision(data: {
        'companyId': companyId,
        'module': module,
        'decisionType': decisionType,
        'payload': payload,
        'justification': justification,
      });
      state = AsyncValue.data(decision);
      return decision;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final decisionFormNotifierProvider =
    StateNotifierProvider.autoDispose<DecisionFormNotifier, AsyncValue<DecisionModel?>>(
  (ref) => DecisionFormNotifier(ref.watch(decisionRemoteDataSourceProvider)),
);
