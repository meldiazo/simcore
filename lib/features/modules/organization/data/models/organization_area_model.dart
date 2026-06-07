import 'organization_position_model.dart';

class OrganizationAreaModel {
  const OrganizationAreaModel({
    this.areaId,
    required this.name,
    this.description,
    this.positions = const [],
  });

  final String? areaId;
  final String name;
  final String? description;
  final List<OrganizationPositionModel> positions;

  Map<String, dynamic> toJson() => {
        if (areaId != null) 'id': areaId,
        'name': name,
        'description': description,
      };
}
