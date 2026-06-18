class InterventionModel {
  const InterventionModel({
    required this.id,
    required this.companyId,
    required this.type,
    required this.message,
    this.targetModule,
    this.createdBy,
    this.createdAt,
  });

  final int id;
  final int companyId;
  final String type;
  final String message;
  final String? targetModule;
  final String? createdBy;
  final DateTime? createdAt;

  factory InterventionModel.fromJson(Map<String, dynamic> json) {
    return InterventionModel(
      id: _readInt(json['id']) ?? 0,
      companyId: _readInt(json['companyId']) ?? 0,
      type: json['type']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      targetModule: json['targetModule']?.toString(),
      createdBy: json['createdBy']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

class CreateInterventionRequest {
  const CreateInterventionRequest({
    required this.type,
    required this.message,
    this.targetModule,
  });

  final String type;
  final String message;
  final String? targetModule;

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      'targetModule': targetModule,
    }..removeWhere((_, value) => value == null);
  }
}

int? _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
