class DecisionImpact {
  final String impactId;
  final String decisionId;
  final String affectedModule;
  final String description;
  final double impactValue;

  DecisionImpact({
    required this.impactId,
    required this.decisionId,
    required this.affectedModule,
    required this.description,
    required this.impactValue,
  });
}