import 'package:simcore_frontend/features/simulation/shared/domain/entities/simulation_context.dart';

class SimulationContextModel extends SimulationContext {
  const SimulationContextModel({
    required super.companyId,
    required super.groupId,
    required super.courseId,
    super.scenarioId,
    super.companyName,
  });

  /// Mapea desde la respuesta de GET /api/v1/simulation/companies/{id}
  factory SimulationContextModel.fromCompanyJson(Map<String, dynamic> json) {
    return SimulationContextModel(
      companyId: json['id'] as int,
      groupId: json['groupId'] as int,
      courseId: json['courseId'] as int,
      scenarioId: json['scenarioId'] as int?,
      companyName: json['name'] as String?,
    );
  }

  /// Contexto de desarrollo para mock/local sin backend.
  factory SimulationContextModel.devDefault() {
    return const SimulationContextModel(
      companyId: 1,
      groupId: 1,
      courseId: 1,
      scenarioId: null,
      companyName: 'Equipo Alpha (demo)',
    );
  }
}