import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/features/comparison/data/datasources/comparison_remote_datasource.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/scenario_context_provider.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

final courseComparisonProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return {'companies': []};
  final scenarioType = ref.watch(selectedScenarioTypeProvider);
  return ref.watch(comparisonDataSourceProvider).getCourseComparison(
    courseId: ctx.courseId,
    scenarioType: scenarioType,
  );
});
