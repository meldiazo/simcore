import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/teacher/data/datasources/intervention_remote_datasource.dart';
import 'package:simcore_frontend/features/teacher/data/models/intervention_model.dart';
import 'package:simcore_frontend/features/teacher/presentation/providers/teacher_dashboard_providers.dart';

final interventionRemoteDataSourceProvider =
    Provider<InterventionRemoteDataSource>((ref) {
  return InterventionRemoteDataSource(ref.watch(simulationApiClientProvider));
});

final companyInterventionsProvider =
    FutureProvider.family<List<InterventionModel>, int>((ref, companyId) {
  return ref
      .watch(interventionRemoteDataSourceProvider)
      .listInterventions(companyId: companyId);
});

class InterventionNotifier extends StateNotifier<AsyncValue<void>> {
  InterventionNotifier(this._dataSource, this._ref)
      : super(const AsyncValue.data(null));

  final InterventionRemoteDataSource _dataSource;
  final Ref _ref;

  Future<bool> create({
    required int companyId,
    required CreateInterventionRequest request,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _dataSource.createIntervention(
        companyId: companyId,
        request: request,
      );
      if (!mounted) return false;
      state = const AsyncValue.data(null);
      _ref.invalidate(companyInterventionsProvider(companyId));
      _ref.invalidate(teacherDashboardProvider);
      return true;
    } catch (e, st) {
      if (!mounted) return false;
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final interventionNotifierProvider =
    StateNotifierProvider<InterventionNotifier, AsyncValue<void>>((ref) {
  return InterventionNotifier(
      ref.watch(interventionRemoteDataSourceProvider), ref);
});
