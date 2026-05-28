import '../../domain/entities/scenario.dart';
import '../datasources/scenario_remote_datasource.dart';
import '../models/scenario_model.dart';

class ScenarioRepositoryImpl implements ScenarioRepository {
  final ScenarioRemoteDataSource remoteDataSource;
  ScenarioRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Scenario>> getScenariosByCourse(int courseId) async {
    return await remoteDataSource.getScenariosByCourse(courseId);
  }

  @override
  Future<Scenario> getActiveScenario(int groupId) async {
    return await remoteDataSource.getActiveScenario(groupId);
  }

  @override
  Future<Scenario> getScenarioById(int id) async {
    return await remoteDataSource.getScenarioById(id);
  }

  @override
  Future<Scenario> createScenario(Scenario scenario) async {
    final model = ScenarioModel(
      id: scenario.id,
      courseId: scenario.courseId,
      name: scenario.name,
      description: scenario.description,
      type: scenario.type,
      isActive: scenario.isActive,
      variables: scenario.variables,
    );
    return await remoteDataSource.createScenario(model);
  }

  @override
  Future<void> activateScenario(int id) => remoteDataSource.activateScenario(id);

  @override
  Future<void> deactivateScenario(int id) => remoteDataSource.deactivateScenario(id);

  @override
  Future<void> assignScenario(int id, int groupId) => remoteDataSource.assignScenario(id, groupId);

  @override
  Future<void> updateVariable(int scenarioId, String code, double value) => remoteDataSource.updateVariable(scenarioId, code, value);
}