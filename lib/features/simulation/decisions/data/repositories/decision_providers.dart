import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/models/decision_impact_model.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/models/decision_model.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/repositories/decision_repository_impl.dart';
import 'package:simcore_frontend/features/simulation/decisions/datasources/decision_remote_datasource.dart';
import 'package:simcore_frontend/features/simulation/decisions/repositories/decision_repository.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

// 1. Inyección del Datasource
final decisionRemoteDatasourceProvider = Provider<DecisionRemoteDatasource>((ref) {
  return DecisionRemoteDatasource();
});

// 2. Inyección del Repositorio
final decisionRepositoryProvider = Provider<DecisionRepository>((ref) {
  final datasource = ref.watch(decisionRemoteDatasourceProvider);
  return DecisionRepositoryImpl(remoteDatasource: datasource);
});

// 3. Provider para OBTENER todas las decisiones de la compañía actual
final companyDecisionsProvider = FutureProvider<List<DecisionModel>>((ref) async {
  final companyId = ref.watch(currentCompanyIdProvider);
  final repository = ref.watch(decisionRepositoryProvider);
  return repository.getCompanyDecisions(companyId.toString());
});

// 4. Provider para OBTENER el impacto de una decisión específica
final decisionImpactProvider = FutureProvider.family<List<DecisionImpactModel>, String>((ref, decisionId) async {
  final repository = ref.watch(decisionRepositoryProvider);
  return repository.getDecisionImpact(decisionId);
});

// 5. Notifier para CREAR una nueva decisión (maneja el estado de la acción POST)
class DecisionNotifier extends StateNotifier<AsyncValue<void>> {
  final DecisionRepository _repository;
  final Ref _ref;

  DecisionNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> createDecision(DecisionModel decision) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createDecision(decision);
      state = const AsyncValue.data(null);
      // Al crear una decisión, invalidamos el provider que lista todas
      // para que la UI se refresque con la nueva decisión.
      _ref.invalidate(companyDecisionsProvider);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

final decisionNotifierProvider = StateNotifierProvider<DecisionNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(decisionRepositoryProvider);
  return DecisionNotifier(repository, ref);
});