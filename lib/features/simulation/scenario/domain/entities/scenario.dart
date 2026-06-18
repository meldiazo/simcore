import 'package:equatable/equatable.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';

class ScenarioVariable extends Equatable {
  const ScenarioVariable({
    required this.code,
    required this.value,
    this.displayName,
    this.unit,
    this.minValue,
    this.maxValue,
    this.locked = false,
    this.description,
  });

  final String code;
  final String value;
  final String? displayName;
  final String? unit;
  final double? minValue;
  final double? maxValue;
  final bool locked;
  final String? description;

  @override
  List<Object?> get props => [
        code,
        value,
        displayName,
        unit,
        minValue,
        maxValue,
        locked,
        description,
      ];
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
    this.groupsCanSeeEachOther = false,
    this.blockR1 = true,
    this.blockR2 = true,
    this.blockR3 = true,
    this.blockR4 = true,
    this.blockR5 = true,
    this.blockR6 = true,
  });

  final int id;
  final int courseId;
  final String name;
  final ScenarioType type;
  final String status;
  final String? description;
  final List<ScenarioVariable> variables;
  final bool groupsCanSeeEachOther;
  final bool blockR1;
  final bool blockR2;
  final bool blockR3;
  final bool blockR4;
  final bool blockR5;
  final bool blockR6;

  @override
  List<Object?> get props => [
        id,
        courseId,
        name,
        type,
        status,
        description,
        variables,
        groupsCanSeeEachOther,
        blockR1,
        blockR2,
        blockR3,
        blockR4,
        blockR5,
        blockR6,
      ];
}
