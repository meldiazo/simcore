import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';
import 'package:simcore_frontend/features/teacher/data/datasources/evaluation_remote_datasource.dart';
import 'package:simcore_frontend/features/teacher/data/models/evaluation_model.dart';
import 'package:simcore_frontend/features/teacher/presentation/providers/teacher_dashboard_providers.dart';

final evaluationRemoteDataSourceProvider =
    Provider<EvaluationRemoteDataSource>((ref) {
  return EvaluationRemoteDataSource(ref.watch(simulationApiClientProvider));
});

final courseEvaluationsProvider = FutureProvider<List<EvaluationModel>>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(const []);
  return ref.watch(evaluationRemoteDataSourceProvider).listEvaluations(
        courseId: ctx.courseId,
      );
});

final groupEvaluationProvider =
    FutureProvider.family<EvaluationModel?, int>((ref, groupId) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(null);
  return ref.watch(evaluationRemoteDataSourceProvider).getEvaluation(
        courseId: ctx.courseId,
        groupId: groupId,
      );
});

class EvaluationNotifier extends StateNotifier<AsyncValue<void>> {
  EvaluationNotifier(this._dataSource, this._ref)
      : super(const AsyncValue.data(null));

  final EvaluationRemoteDataSource _dataSource;
  final Ref _ref;

  Future<bool> save({
    required int groupId,
    required UpsertEvaluationRequest request,
  }) async {
    final ctx = _ref.read(simulationContextNotifierProvider).context;
    if (ctx == null) return false;

    state = const AsyncValue.loading();
    try {
      await _dataSource.upsertEvaluation(
        courseId: ctx.courseId,
        groupId: groupId,
        request: request,
      );
      if (!mounted) return false;
      state = const AsyncValue.data(null);
      _ref.invalidate(courseEvaluationsProvider);
      _ref.invalidate(groupEvaluationProvider(groupId));
      _ref.invalidate(teacherDashboardProvider);
      return true;
    } catch (e, st) {
      if (!mounted) return false;
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final evaluationNotifierProvider =
    StateNotifierProvider<EvaluationNotifier, AsyncValue<void>>((ref) {
  return EvaluationNotifier(ref.watch(evaluationRemoteDataSourceProvider), ref);
});
