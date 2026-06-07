import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/teacher/data/datasources/teacher_dashboard_remote_datasource.dart';
import 'package:simcore_frontend/features/teacher/data/models/teacher_dashboard_model.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

final teacherDashboardRemoteDataSourceProvider =
    Provider<TeacherDashboardRemoteDataSource>((ref) {
  return TeacherDashboardRemoteDataSource(ref.watch(simulationApiClientProvider));
});

final teacherDashboardProvider = FutureProvider<TeacherDashboard>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) {
    return Future.value(TeacherDashboard(
      courseId: 0,
      totalGroups: 0,
      activeCompanies: 0,
      groups: const [],
    ));
  }
  return ref
      .watch(teacherDashboardRemoteDataSourceProvider)
      .getDashboard(courseId: ctx.courseId);
});
