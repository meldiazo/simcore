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

  if (ctx == null) {
    return Future.value(const []);
  }

  return ref
      .watch(scenarioRemoteDataSourceProvider)
      .getScenariosByCourse(courseId: ctx.courseId);
});

final activeScenarioProvider = FutureProvider<Scenario?>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;

  if (ctx == null) {
    return Future.value(null);
  }

  return ref
      .watch(scenarioRemoteDataSourceProvider)
      .getActiveScenario(groupId: ctx.groupId);
});

class ScenarioFormNotifier extends StateNotifier<AsyncValue<Scenario?>> {
  ScenarioFormNotifier(this._ds) : super(const AsyncValue.data(null));

  final ScenarioRemoteDataSource _ds;

  Future<Scenario?> createScenario(Map<String, dynamic> data) async {
    if (!mounted) return null;

    state = const AsyncValue.loading();

    try {
      final scenario = await _ds.createScenario(data: data);

      if (!mounted) return scenario;

      state = AsyncValue.data(scenario);
      return scenario;
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
      return null;
    }
  }

  Future<Scenario?> activateScenario(int id) async {
    if (!mounted) return null;

    state = const AsyncValue.loading();

    try {
      final scenario = await _ds.activateScenario(id: id);

      if (!mounted) return scenario;

      state = AsyncValue.data(scenario);
      return scenario;
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
      return null;
    }
  }

  Future<bool> assignToGroup({
    required int scenarioId,
    required int groupId,
  }) async {
    if (!mounted) return false;

    state = const AsyncValue.loading();

    try {
      await _ds.assignScenarioToGroup(
        scenarioId: scenarioId,
        groupId: groupId,
      );

      if (mounted) {
        state = const AsyncValue.data(null);
      }

      return true;
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
      return false;
    }
  }
}

final scenarioFormNotifierProvider =
    StateNotifierProvider<ScenarioFormNotifier, AsyncValue<Scenario?>>(
  (ref) => ScenarioFormNotifier(ref.watch(scenarioRemoteDataSourceProvider)),
);