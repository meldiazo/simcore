import '../../domain/entities/company.dart';

class CompanyModel extends Company {
  const CompanyModel({
    required super.id,
    required super.name,
    required super.groupId,
    super.sector,
    super.industry,
    super.description,
    super.mission,
    super.vision,
    super.status,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      groupId: json['groupId'] ?? 0,
      sector: CompanySector.values.firstWhere(
        (e) => e.name == json['sector'], 
        orElse: () => CompanySector.other
      ),
      industry: json['industry'],
      description: json['description'],
      mission: json['mission'],
      vision: json['vision'],
      status: CompanyStatus.values.firstWhere(
        (e) => e.name == json['status'], 
        orElse: () => CompanyStatus.unknown
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'groupId': groupId,
    'sector': sector.name,
    'industry': industry,
    'description': description,
    'mission': mission,
    'vision': vision,
    'status': status.name,
  };
}