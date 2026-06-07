import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/features/teacher/data/models/teacher_dashboard_model.dart';

class TeacherDashboardRemoteDataSource {
  TeacherDashboardRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<TeacherDashboard> getDashboard({
    required int courseId,
    String scenarioType = 'PROBABLE',
  }) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/courses/$courseId/teacher-dashboard',
      queryParameters: {'scenarioType': scenarioType},
    );
    return result.fold(
      (e) => throw e,
      (data) {
        if (data == null) {
          return TeacherDashboard(
            courseId: courseId,
            totalGroups: 0,
            activeCompanies: 0,
            groups: const [],
          );
        }
        return TeacherDashboard.fromJson(Map<String, dynamic>.from(data as Map));
      },
    );
  }
}
