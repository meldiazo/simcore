class Decision {
  const Decision({
    required this.id,
    required this.companyId,
    required this.module,
    required this.decisionType,
    required this.payload,
    required this.justification,
    required this.status,
    this.decisionVersion = 1,
  });

  final int id;
  final int companyId;
  final String module;
  final String decisionType;
  final String payload;
  final String justification;
  final String status;
  final int decisionVersion;
}
