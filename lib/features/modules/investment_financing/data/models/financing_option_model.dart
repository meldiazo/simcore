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

  /// Valor para mostrar en pantalla como porcentaje.
  /// Backend puede devolver 0.12, pero la UI debe mostrar 12%.
  final double interestRate;

  final int termInMonths;
  final bool isSelected;

  factory FinancingOptionModel.fromJson(Map<String, dynamic> json) {
    final rawRate =
        _readDouble(json, 'interestRate') ?? _readDouble(json, 'annualInterestRate') ?? 0;

    return FinancingOptionModel(
      id: (json['id'] ?? '').toString(),
      type: FinancingType.fromJson(
        (json['type'] ?? json['sourceType'])?.toString(),
      ),
      amount: _readDouble(json, 'amount') ??
          _readDouble(json, 'principalAmount') ??
          0,
      interestRate: _rateForDisplay(rawRate),
      termInMonths: _readInt(json, 'termInMonths') ??
          _readInt(json, 'termMonths') ??
          0,
      isSelected: json['isSelected'] == true || json['selected'] == true,
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

  static double _rateForDisplay(double value) {
    if (value <= 1.0) return value * 100;
    return value;
  }

  static double? _readDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}