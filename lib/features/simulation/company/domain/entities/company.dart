import 'package:equatable/equatable.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';

class Company extends Equatable {
  const Company({
    required this.id,
    required this.name,
    required this.groupId,
    required this.status,
  });

  final int id;
  final String name;
  final int groupId;
  final CompanyStatus status;

  @override
  List<Object?> get props => [id, name, groupId, status];
}
