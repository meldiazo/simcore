import 'package:equatable/equatable.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';

class ScenarioContext extends Equatable {
  const ScenarioContext({
    required this.companyId,
    required this.groupId,
    required this.courseId,
    required this.scenarioType,
    this.scenarioId,
    this.scenarioName,
    this.isFallback = false,
  });

  factory ScenarioContext.fallback({
    required int companyId,
    required int groupId,
    required int courseId,
    int? scenarioId,
  }) {
    return ScenarioContext(
      companyId: companyId,
      groupId: groupId,
      courseId: courseId,
      scenarioId: scenarioId,
      scenarioType: ScenarioType.probable,
      isFallback: true,
    );
  }

  final int companyId;
  final int groupId;
  final int courseId;
  final int? scenarioId;
  final String? scenarioName;
  final ScenarioType scenarioType;
  final bool isFallback;

  String get scenarioTypeApi => scenarioType.toApi();

  @override
  List<Object?> get props => [
        companyId,
        groupId,
        courseId,
        scenarioId,
        scenarioName,
        scenarioType,
        isFallback,
      ];
}
