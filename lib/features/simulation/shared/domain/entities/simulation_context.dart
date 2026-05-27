import 'package:equatable/equatable.dart';

class SimulationContext extends Equatable {
  const SimulationContext({
    required this.companyId,
    required this.groupId,
    required this.courseId,
    this.scenarioId,
    this.companyName,
  });

  final int companyId;
  final int groupId;
  final int courseId;
  final int? scenarioId;
  final String? companyName;

  @override
  List<Object?> get props =>
      [companyId, groupId, courseId, scenarioId, companyName];
}