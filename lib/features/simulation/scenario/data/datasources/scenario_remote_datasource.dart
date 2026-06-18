import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/features/simulation/scenario/data/models/scenario_model.dart';
import 'package:simcore_frontend/features/simulation/scenario/domain/entities/scenario.dart';

class ScenarioRemoteDataSource {
  ScenarioRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Scenario>> getScenariosByCourse({required int courseId}) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/scenarios',
      queryParameters: {'courseId': courseId},
    );
    return result.fold(
      (e) => throw e,
      (data) => _extractList(data).map(ScenarioModel.fromJson).toList(),
    );
  }

  Future<Scenario?> getActiveScenario({required int groupId}) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/scenarios/active',
      queryParameters: {'groupId': groupId},
    );
    return result.fold(
      (e) => throw e,
      (data) {
        if (data == null) return null;
        return ScenarioModel.fromJson(Map<String, dynamic>.from(data as Map));
      },
    );
  }

  Future<Scenario> getScenarioById({required int id}) async {
    final result = await _apiClient.get('/api/v1/simulation/scenarios/$id');
    return result.fold(
      (e) => throw e,
      (data) => ScenarioModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<Scenario> createScenario({required Map<String, dynamic> data}) async {
    final result =
        await _apiClient.post('/api/v1/simulation/scenarios', data: data);
    return result.fold(
      (e) => throw e,
      (d) => ScenarioModel.fromJson(Map<String, dynamic>.from(d as Map)),
    );
  }

  Future<Scenario> activateScenario({required int id}) async {
    final result =
        await _apiClient.patch('/api/v1/simulation/scenarios/$id/activate');
    return result.fold(
      (e) => throw e,
      (d) => ScenarioModel.fromJson(Map<String, dynamic>.from(d as Map)),
    );
  }

  Future<Scenario> deactivateScenario({required int id}) async {
    final result =
        await _apiClient.patch('/api/v1/simulation/scenarios/$id/deactivate');
    return result.fold(
      (e) => throw e,
      (d) => ScenarioModel.fromJson(Map<String, dynamic>.from(d as Map)),
    );
  }

  Future<void> assignScenarioToGroup(
      {required int scenarioId, required int groupId}) async {
    final result = await _apiClient.put(
      '/api/v1/simulation/scenarios/$scenarioId/assign',
      data: {'groupId': groupId},
    );
    result.fold((e) => throw e, (_) {});
  }

  Future<ScenarioVariable> updateVariable({
    required int scenarioId,
    required String code,
    required num value,
  }) async {
    final result = await _apiClient.patch(
      '/api/v1/simulation/scenarios/$scenarioId/variables/$code',
      data: {'value': value},
    );
    return result.fold(
      (e) => throw e,
      (data) => ScenarioVariableModel.fromJson(
          Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<Scenario> setIncoherenceConfig({
    required int scenarioId,
    required Map<String, bool> config,
  }) async {
    final result = await _apiClient.patch(
      '/api/v1/simulation/scenarios/$scenarioId/incoherence-config',
      data: config,
    );
    return result.fold(
      (e) => throw e,
      (data) => ScenarioModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<Scenario> setVisibility({
    required int scenarioId,
    required bool groupsCanSeeEachOther,
  }) async {
    final result = await _apiClient.patch(
      '/api/v1/simulation/scenarios/$scenarioId/visibility?groupsCanSeeEachOther=$groupsCanSeeEachOther',
    );
    return result.fold(
      (e) => throw e,
      (data) => ScenarioModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<void> deleteScenario({required int id}) async {
    final result = await _apiClient.delete('/api/v1/simulation/scenarios/$id');
    result.fold((e) => throw e, (_) {});
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is Map) {
      final json = Map<String, dynamic>.from(data);
      for (final key in ['data', 'content', 'items', 'scenarios']) {
        final value = json[key];
        if (value is List) {
          return value
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    }
    return const [];
  }
}
