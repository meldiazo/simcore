import '../../domain/entities/scenario.dart';
import '../datasources/scenario_remote_datasource.dart';

class ScenarioRepositoryImpl {
  final ScenarioRemoteDataSource remoteDataSource;
  ScenarioRepositoryImpl(this.remoteDataSource);

  Future<List<Scenario>> getScenariosByCourse(int courseId) async {
    return remoteDataSource.getScenariosByCourse(courseId: courseId);
  }

  Future<Scenario> getActiveScenario(int groupId) async {
    final active = await remoteDataSource.getActiveScenario(groupId: groupId);
    if (active != null) return active;
    return remoteDataSource.getScenarioById(id: 0);
  }

  Future<Scenario> getScenarioById(int id) async {
    return remoteDataSource.getScenarioById(id: id);
  }

  Future<Scenario> createScenario(Scenario scenario) async {
    return remoteDataSource.createScenario(
      data: {
        'id': scenario.id,
        'courseId': scenario.courseId,
        'name': scenario.name,
        'description': scenario.description,
        'type': scenario.type.toApi(),
        'status': scenario.status,
        'variables': scenario.variables
            .map((v) => {
                  'code': v.code,
                  'value': v.value,
                  'description': v.description,
                })
            .toList(),
      },
    );
  }

  Future<void> activateScenario(int id) async {
    await remoteDataSource.activateScenario(id: id);
  }

  Future<void> deactivateScenario(int id) async {
    await remoteDataSource.deactivateScenario(id: id);
  }

  Future<void> assignScenario(int id, int groupId) {
    return remoteDataSource.assignScenarioToGroup(
      scenarioId: id,
      groupId: groupId,
    );
  }

  Future<void> updateVariable(int scenarioId, String code, double value) async {}
}
