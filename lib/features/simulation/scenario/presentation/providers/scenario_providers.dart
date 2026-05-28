import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/simulation/scenario/data/datasources/scenario_remote_datasource.dart';
import 'package:simcore_frontend/features/simulation/scenario/domain/entities/scenario.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

final scenarioRemoteDataSourceProvider = Provider<ScenarioRemoteDataSource>((ref) {
  return ScenarioRemoteDataSource(ref.watch(simulationApiClientProvider));
});

final scenariosByCourseProvider = FutureProvider<List<Scenario>>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(const []);
  return ref.watch(scenarioRemoteDataSourceProvider).getScenariosByCourse(courseId: ctx.courseId);
});

final activeScenarioProvider = FutureProvider<Scenario?>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return Future.value(null);
  return ref.watch(scenarioRemoteDataSourceProvider).getActiveScenario(groupId: ctx.groupId);
});

class ScenarioFormNotifier extends StateNotifier<AsyncValue<Scenario?>> {
  ScenarioFormNotifier(this._ds) : super(const AsyncValue.data(null));
  final ScenarioRemoteDataSource _ds;

  Future<Scenario?> createScenario(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final scenario = await _ds.createScenario(data: data);
      state = AsyncValue.data(scenario);
      return scenario;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<Scenario?> activateScenario(int id) async {
    state = const AsyncValue.loading();
    try {
      final scenario = await _ds.activateScenario(id: id);
      state = AsyncValue.data(scenario);
      return scenario;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> assignToGroup({required int scenarioId, required int groupId}) async {
    state = const AsyncValue.loading();
    try {
      await _ds.assignScenarioToGroup(scenarioId: scenarioId, groupId: groupId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final scenarioFormNotifierProvider =
    StateNotifierProvider.autoDispose<ScenarioFormNotifier, AsyncValue<Scenario?>>(
  (ref) => ScenarioFormNotifier(ref.watch(scenarioRemoteDataSourceProvider)),
);
