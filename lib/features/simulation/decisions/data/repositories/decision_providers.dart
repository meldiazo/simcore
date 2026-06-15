import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/datasources/decision_remote_datasource.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/models/decision_impact_model.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/models/decision_model.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/repositories/decision_repository_impl.dart';
import 'package:simcore_frontend/features/simulation/decisions/repositories/decision_repository.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

final decisionRemoteDataSourceProvider = Provider<DecisionRemoteDataSource>((ref) {
  return DecisionRemoteDataSource(ref.watch(simulationApiClientProvider));
});

final decisionRepositoryProvider = Provider<DecisionRepository>((ref) {
  final dataSource = ref.watch(decisionRemoteDataSourceProvider);
  return DecisionRepositoryImpl(remoteDatasource: dataSource);
});

final companyDecisionsProvider =
    FutureProvider<List<DecisionModel>>((ref) async {
  final companyId = ref.watch(currentCompanyIdProvider);
  final repository = ref.watch(decisionRepositoryProvider);
  return repository.getCompanyDecisions(companyId.toString());
});

final decisionImpactProvider =
    FutureProvider.family<List<DecisionImpactModel>, String>(
        (ref, decisionId) async {
  final repository = ref.watch(decisionRepositoryProvider);
  return repository.getDecisionImpact(decisionId);
});

class DecisionNotifier extends StateNotifier<AsyncValue<void>> {
  DecisionNotifier(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  final DecisionRepository _repository;
  final Ref _ref;

  Future<bool> createDecision(DecisionModel decision) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createDecision(decision);
      state = const AsyncValue.data(null);
      _ref.invalidate(companyDecisionsProvider);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

final decisionNotifierProvider =
    StateNotifierProvider<DecisionNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(decisionRepositoryProvider);
  return DecisionNotifier(repository, ref);
});
