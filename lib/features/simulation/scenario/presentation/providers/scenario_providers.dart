import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/simulation/scenario/data/datasources/scenario_remote_datasource.dart';
import 'package:simcore_frontend/features/simulation/scenario/domain/entities/scenario.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

final scenarioRemoteDataSourceProvider =
    Provider<ScenarioRemoteDataSource>((ref) {
  return ScenarioRemoteDataSource(ref.watch(simulationApiClientProvider));
});

final selectedScenarioCourseIdProvider = StateProvider<int?>((ref) => null);

final scenariosByCourseIdProvider =
    FutureProvider.family<List<Scenario>, int>((ref, courseId) {
  return ref
      .watch(scenarioRemoteDataSourceProvider)
      .getScenariosByCourse(courseId: courseId);
});

final scenariosByCourseProvider = FutureProvider<List<Scenario>>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;

  if (ctx == null) {
    return Future.value(const []);
  }

  return ref.watch(scenariosByCourseIdProvider(ctx.courseId).future);
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
  ScenarioFormNotifier(this._ds, this._ref)
      : super(const AsyncValue.data(null));

  final ScenarioRemoteDataSource _ds;
  final Ref _ref;

  Future<Scenario?> createScenario(Map<String, dynamic> data) async {
    if (!mounted) return null;

    state = const AsyncValue.loading();

    try {
      final scenario = await _ds.createScenario(data: data);

      if (!mounted) return scenario;

      state = AsyncValue.data(scenario);
      _invalidateScenarios();
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
      _invalidateScenarios();
      return scenario;
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
      return null;
    }
  }

  Future<Scenario?> deactivateScenario(int id) async {
    return _scenarioAction(() => _ds.deactivateScenario(id: id));
  }

  Future<Scenario?> setVisibility({
    required int scenarioId,
    required bool groupsCanSeeEachOther,
  }) async {
    return _scenarioAction(
      () => _ds.setVisibility(
        scenarioId: scenarioId,
        groupsCanSeeEachOther: groupsCanSeeEachOther,
      ),
    );
  }

  Future<Scenario?> setIncoherenceConfig({
    required int scenarioId,
    required Map<String, bool> config,
  }) async {
    return _scenarioAction(
      () => _ds.setIncoherenceConfig(
        scenarioId: scenarioId,
        config: config,
      ),
    );
  }

  Future<bool> updateVariable({
    required int scenarioId,
    required String code,
    required num value,
  }) async {
    if (!mounted) return false;

    state = const AsyncValue.loading();
    try {
      await _ds.updateVariable(
        scenarioId: scenarioId,
        code: code,
        value: value,
      );
      if (mounted) {
        state = const AsyncValue.data(null);
        _invalidateScenarios();
      }
      return true;
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteScenario(int id) async {
    if (!mounted) return false;

    state = const AsyncValue.loading();
    try {
      await _ds.deleteScenario(id: id);
      if (mounted) {
        state = const AsyncValue.data(null);
        _invalidateScenarios();
      }
      return true;
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
      return false;
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
        _invalidateScenarios();
      }

      return true;
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
      return false;
    }
  }

  Future<Scenario?> _scenarioAction(Future<Scenario> Function() action) async {
    if (!mounted) return null;

    state = const AsyncValue.loading();
    try {
      final scenario = await action();
      if (mounted) {
        state = AsyncValue.data(scenario);
        _invalidateScenarios();
      }
      return scenario;
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
      return null;
    }
  }

  void _invalidateScenarios() {
    _ref.invalidate(scenariosByCourseProvider);
    _ref.invalidate(scenariosByCourseIdProvider);
    _ref.invalidate(activeScenarioProvider);
  }
}

final scenarioFormNotifierProvider =
    StateNotifierProvider<ScenarioFormNotifier, AsyncValue<Scenario?>>(
  (ref) => ScenarioFormNotifier(
    ref.watch(scenarioRemoteDataSourceProvider),
    ref,
  ),
);
