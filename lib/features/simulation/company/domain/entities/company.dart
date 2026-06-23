import 'package:equatable/equatable.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';

class Company extends Equatable {
  const Company({
    required this.id,
    required this.name,
    required this.groupId,
    required this.status,
    this.sector = '',
    this.industry = '',
    this.description = '',
    this.mission = '',
    this.vision = '',
    this.simulationType = SimulationType.startup,
  });

  final int id;
  final String name;
  final int groupId;
  final CompanyStatus status;
  final String sector;
  final String industry;
  final String description;
  final String mission;
  final String vision;
  final SimulationType simulationType;

  @override
  List<Object?> get props => [
        id,
        name,
        groupId,
        status,
        sector,
        industry,
        description,
        mission,
        vision,
        simulationType,
      ];
}
