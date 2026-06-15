import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/teacher/data/datasources/teacher_dashboard_remote_datasource.dart';
import 'package:simcore_frontend/features/teacher/data/models/teacher_dashboard_model.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/scenario_context_provider.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

import 'package:simcore_frontend/core/config/app_config.dart';

final teacherDashboardRemoteDataSourceProvider =
    Provider<TeacherDashboardRemoteDataSource>((ref) {
  return TeacherDashboardRemoteDataSource(
      ref.watch(simulationApiClientProvider));
});

final teacherDashboardProvider = FutureProvider<TeacherDashboard>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMockData) {
    return Future.value(const TeacherDashboard(
      courseId: 1,
      totalGroups: 2,
      activeCompanies: 2,
      groups: [
        GroupDashboardItem(
          groupId: 1,
          groupName: 'Equipo Alpha',
          companyId: 10,
          companyName: 'AlphaCorp',
          companyStatus: 'IN_SIMULATION',
          completedModules: 3,
          moduleProgress: [
            {'module': 'Mercado', 'status': 'COMPLETE'},
            {'module': 'Inversión y Financiamiento', 'status': 'IN_PROGRESS'},
            {'module': 'Estructuras Organizativas', 'status': 'PENDING'},
          ],
          incoherences: {'total': 2, 'high': 0},
        ),
        GroupDashboardItem(
          groupId: 2,
          groupName: 'Equipo Beta',
          companyId: 11,
          companyName: 'BetaCorp',
          companyStatus: 'IN_SIMULATION',
          completedModules: 1,
          moduleProgress: [
            {'module': 'Mercado', 'status': 'IN_PROGRESS'},
          ],
          incoherences: {'total': 5, 'high': 2},
        ),
      ],
    ));
  }

  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) {
    return Future.value(TeacherDashboard(
      courseId: 0,
      totalGroups: 0,
      activeCompanies: 0,
      groups: const [],
    ));
  }
  final scenarioType = ref.watch(selectedScenarioTypeProvider);
  return ref
      .watch(teacherDashboardRemoteDataSourceProvider)
      .getDashboard(courseId: ctx.courseId, scenarioType: scenarioType);
});
