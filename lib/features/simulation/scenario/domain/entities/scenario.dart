enum ScenarioType { OPTIMISTIC, PROBABLE, PESSIMISTIC, UNKNOWN }

class ScenarioVariable {
  final String code;
  final String name;
  final double value;
  final bool isLocked;

  const ScenarioVariable({
    required this.code,
    required this.name,
    required this.value,
    this.isLocked = false,
  });
}

class Scenario {
  final int id;
  final int courseId;
  final String name;
  final String description;
  final ScenarioType type;
  final bool isActive;
  final List<ScenarioVariable> variables;

  const Scenario({
    required this.id,
    required this.courseId,
    required this.name,
    required this.description,
    required this.type,
    this.isActive = false,
    this.variables = const [],
  });
}

abstract class ScenarioRepository {
  Future<List<Scenario>> getScenariosByCourse(int courseId);
  Future<Scenario> getActiveScenario(int groupId);
  Future<Scenario> getScenarioById(int id);
  Future<Scenario> createScenario(Scenario scenario);
  Future<void> activateScenario(int id);
  Future<void> deactivateScenario(int id);
  Future<void> assignScenario(int id, int groupId);
  Future<void> updateVariable(int scenarioId, String code, double value);
}