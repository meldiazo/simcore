import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/features/simulation/scenario/presentation/providers/scenario_providers.dart';
import 'package:simcore_frontend/features/simulation/shared/domain/entities/scenario_context.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

final scenarioContextProvider = FutureProvider<ScenarioContext?>((ref) async {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return null;

  final dataSource = ref.watch(scenarioRemoteDataSourceProvider);
  final scenario = ctx.scenarioId != null
      ? await dataSource.getScenarioById(id: ctx.scenarioId!)
      : await dataSource.getActiveScenario(groupId: ctx.groupId);

  if (scenario == null) {
    return ScenarioContext.fallback(
      companyId: ctx.companyId,
      groupId: ctx.groupId,
      courseId: ctx.courseId,
      scenarioId: ctx.scenarioId,
    );
  }

  return ScenarioContext(
    companyId: ctx.companyId,
    groupId: ctx.groupId,
    courseId: ctx.courseId,
    scenarioId: scenario.id,
    scenarioName: scenario.name,
    scenarioType: scenario.type,
  );
});

final scenarioTypeOverrideProvider = StateProvider<String?>((ref) => null);

final selectedScenarioTypeProvider = Provider<String>((ref) {
  final override = ref.watch(scenarioTypeOverrideProvider);
  if (override != null && override.trim().isNotEmpty) {
    return override;
  }

  final scenarioContext = ref.watch(scenarioContextProvider).valueOrNull;
  return scenarioContext?.scenarioTypeApi ??
      ScenarioContext.fallback(companyId: 0, groupId: 0, courseId: 0)
          .scenarioTypeApi;
});
