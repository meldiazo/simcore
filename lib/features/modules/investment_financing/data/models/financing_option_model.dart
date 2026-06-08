enum FinancingType {
  OWN_CAPITAL('Capital propio'),
  BANK_LOAN('Préstamo bancario'),
  ANGEL_INVESTMENT('Inversión ángel'),
  GOVERNMENT_GRANT('Subvención pública'),
  CROWDFUNDING('Crowdfunding'),
  OTHER('Otro');

  const FinancingType(this.displayName);

  final String displayName;

  static FinancingType fromJson(String? value) {
    return switch ((value ?? '').trim().toUpperCase()) {
      'OWN_CAPITAL' || 'OWNCAPITAL' => FinancingType.OWN_CAPITAL,
      'BANK_LOAN' || 'BANKLOAN' => FinancingType.BANK_LOAN,
      'ANGEL_INVESTMENT' || 'ANGELINVESTMENT' => FinancingType.ANGEL_INVESTMENT,
      'GOVERNMENT_GRANT' || 'GOVERNMENTGRANT' => FinancingType.GOVERNMENT_GRANT,
      'CROWDFUNDING' => FinancingType.CROWDFUNDING,
      _ => FinancingType.OTHER,
    };
  }
}

class FinancingOptionModel {
  const FinancingOptionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.interestRate,
    required this.termInMonths,
    this.isSelected = false,
  });

  final String id;
  final FinancingType type;
  final double amount;
  final double interestRate;
  final int termInMonths;
  final bool isSelected;

  factory FinancingOptionModel.fromJson(Map<String, dynamic> json) {
    return FinancingOptionModel(
      id: (json['id'] ?? '').toString(),
      type: FinancingType.fromJson(
        (json['type'] ?? json['sourceType'])?.toString(),
      ),
      amount: (json['amount'] as num?)?.toDouble() ??
          (json['principalAmount'] as num?)?.toDouble() ??
          0,
      interestRate: (json['interestRate'] as num?)?.toDouble() ??
          (json['annualInterestRate'] as num?)?.toDouble() ??
          0,
      termInMonths: (json['termInMonths'] as num?)?.toInt() ??
          (json['termMonths'] as num?)?.toInt() ??
          0,
      isSelected: json['isSelected'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'amount': amount,
        'interestRate': interestRate,
        'termInMonths': termInMonths,
        'isSelected': isSelected,
      };
}
