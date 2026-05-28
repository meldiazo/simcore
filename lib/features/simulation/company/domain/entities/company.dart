enum CompanySector { retail, manufacturing, services, technology, other }
enum CompanyStatus { draft, inSimulation, closed, unknown }

class Company {
  final int id;
  final String name;
  final int groupId;
  final CompanySector sector;
  final String? industry;
  final String? description;
  final String? mission;
  final String? vision;
  final CompanyStatus status;

  const Company({
    required this.id,
    required this.name,
    required this.groupId,
    this.sector = CompanySector.other,
    this.industry,
    this.description,
    this.mission,
    this.vision,
    this.status = CompanyStatus.unknown,
  });
}

class SimulationScenario {
  final int id;
  final String name;
  final String description;

  const SimulationScenario({
    required this.id,
    required this.name,
    required this.description,
  });
}

class Incoherence {
  final int id;
  final String title;
  final String message;

  const Incoherence({
    required this.id,
    required this.title,
    required this.message,
  });
}

class DecisionLog {
  final int id;
  final String module;
  final String description;

  const DecisionLog({
    required this.id,
    required this.module,
    required this.description,
  });
}