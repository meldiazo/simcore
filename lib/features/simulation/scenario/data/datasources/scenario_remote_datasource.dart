import 'package:simcore_frontend/core/network/api_client_providers.dart'; // Ajusta si tu ApiClient vive en otra ruta
import '../models/scenario_model.dart';

class ScenarioRemoteDataSource {
  final dynamic dio; // Instancia de tu ApiClient inyectado
  ScenarioRemoteDataSource(this.dio);

  Future<List<ScenarioModel>> getScenariosByCourse(int courseId) async {
    final response = await dio.get('/api/v1/simulation/scenarios?courseId=$courseId');
    return (response.data as List).map((e) => ScenarioModel.fromJson(e)).toList();
  }

  Future<ScenarioModel> getActiveScenario(int groupId) async {
    final response = await dio.get('/api/v1/simulation/scenarios/active?groupId=$groupId');
    return ScenarioModel.fromJson(response.data);
  }

  Future<ScenarioModel> getScenarioById(int id) async {
    final response = await dio.get('/api/v1/simulation/scenarios/$id');
    return ScenarioModel.fromJson(response.data);
  }

  Future<ScenarioModel> createScenario(ScenarioModel model) async {
    final response = await dio.post('/api/v1/simulation/scenarios', data: model.toJson());
    return ScenarioModel.fromJson(response.data);
  }

  Future<void> activateScenario(int id) async {
    await dio.patch('/api/v1/simulation/scenarios/$id/activate');
  }

  Future<void> deactivateScenario(int id) async {
    await dio.patch('/api/v1/simulation/scenarios/$id/deactivate');
  }

  Future<void> assignScenario(int id, int groupId) async {
    await dio.put('/api/v1/simulation/scenarios/$id/assign', data: {'groupId': groupId});
  }

  Future<void> updateVariable(int scenarioId, String code, double value) async {
    await dio.patch('/api/v1/simulation/scenarios/$scenarioId/variables/$code', data: {'value': value});
  }
}