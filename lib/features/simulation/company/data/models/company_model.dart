import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/simulation/company/domain/entities/company.dart';

class CompanyModel extends Company {
  const CompanyModel({
    required super.id,
    required super.name,
    required super.groupId,
    required super.status,
    super.sector = '',
    super.industry = '',
    super.description = '',
    super.mission = '',
    super.vision = '',
    super.simulationType = SimulationType.startup,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: _parseInt(json, ['id', 'companyId']),
      name: (json['name'] ?? json['companyName'] ?? '').toString(),
      groupId: _parseInt(json, ['groupId', 'group_id']),
      status: CompanyStatus.fromApi(
        (json['status'] ?? 'IN_SIMULATION').toString(),
      ),
      sector: (json['sector'] ?? '').toString(),
      industry: (json['industry'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      mission: (json['mission'] ?? '').toString(),
      vision: (json['vision'] ?? '').toString(),
      simulationType: SimulationType.fromApi(
        (json['simulationType'] ?? json['simulation_type'] ?? 'STARTUP').toString(),
      ),
    );
  }

  static int _parseInt(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
    }
    return 0;
  }
}
