import 'package:equatable/equatable.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';

class ScenarioVariable extends Equatable {
  const ScenarioVariable({required this.code, required this.value, this.description});
  final String code;
  final String value;
  final String? description;
  @override
  List<Object?> get props => [code, value];
}

class Scenario extends Equatable {
  const Scenario({
    required this.id,
    required this.courseId,
    required this.name,
    required this.type,
    required this.status,
    this.description,
    this.variables = const [],
  });
  final int id;
  final int courseId;
  final String name;
  final ScenarioType type;
  final String status;
  final String? description;
  final List<ScenarioVariable> variables;
  @override
  List<Object?> get props => [id, courseId, name, type, status];
}
