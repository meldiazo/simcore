class Decision {
  final String id;
  final String companyId;
  final String module;
  final String decisionType;
  final Map<String, dynamic> payload;
  final String justification;
  final DateTime? createdAt;

  Decision({
    required this.id,
    required this.companyId,
    required this.module,
    required this.decisionType,
    required this.payload,
    required this.justification,
    this.createdAt,
  });
}