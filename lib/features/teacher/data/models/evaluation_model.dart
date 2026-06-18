class EvaluationModel {
  const EvaluationModel({
    this.id,
    required this.courseId,
    required this.groupId,
    this.companyId,
    this.marketScore,
    this.investScore,
    this.orgScore,
    this.accountScore,
    this.analysisScore,
    this.oralScore,
    this.coherenceScore,
    this.totalScore,
    this.notes,
    this.evaluatorName,
  });

  final int? id;
  final int courseId;
  final int groupId;
  final int? companyId;
  final double? marketScore;
  final double? investScore;
  final double? orgScore;
  final double? accountScore;
  final double? analysisScore;
  final double? oralScore;
  final double? coherenceScore;
  final double? totalScore;
  final String? notes;
  final String? evaluatorName;

  factory EvaluationModel.fromJson(Map<String, dynamic> json) {
    return EvaluationModel(
      id: _readInt(json['id']),
      courseId: _readInt(json['courseId']) ?? 0,
      groupId: _readInt(json['groupId']) ?? 0,
      companyId: _readInt(json['companyId']),
      marketScore: _readDouble(json['marketScore']),
      investScore: _readDouble(json['investScore']),
      orgScore: _readDouble(json['orgScore']),
      accountScore: _readDouble(json['accountScore']),
      analysisScore: _readDouble(json['analysisScore']),
      oralScore: _readDouble(json['oralScore']),
      coherenceScore: _readDouble(json['coherenceScore']),
      totalScore: _readDouble(json['totalScore']),
      notes: json['notes']?.toString(),
      evaluatorName: json['evaluatorName']?.toString(),
    );
  }
}

class UpsertEvaluationRequest {
  const UpsertEvaluationRequest({
    this.companyId,
    this.marketScore,
    this.investScore,
    this.orgScore,
    this.accountScore,
    this.analysisScore,
    this.oralScore,
    this.coherenceScore,
    this.notes,
  });

  final int? companyId;
  final double? marketScore;
  final double? investScore;
  final double? orgScore;
  final double? accountScore;
  final double? analysisScore;
  final double? oralScore;
  final double? coherenceScore;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'marketScore': marketScore,
      'investScore': investScore,
      'orgScore': orgScore,
      'accountScore': accountScore,
      'analysisScore': analysisScore,
      'oralScore': oralScore,
      'coherenceScore': coherenceScore,
      'notes': notes,
    }..removeWhere((_, value) => value == null);
  }
}

int? _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _readDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
