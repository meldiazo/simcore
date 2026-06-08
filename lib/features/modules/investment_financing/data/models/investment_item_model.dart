enum InvestmentType {
  FIXED_ASSET('Activo fijo'),
  WORKING_CAPITAL('Capital de trabajo'),
  PRE_OPERATIVE('Preoperativo');

  const InvestmentType(this.displayName);

  final String displayName;

  static InvestmentType fromJson(String? value) {
    return switch ((value ?? '').trim().toUpperCase()) {
      'FIXED_ASSET' || 'FIXEDASSET' => InvestmentType.FIXED_ASSET,
      'WORKING_CAPITAL' || 'WORKINGCAPITAL' => InvestmentType.WORKING_CAPITAL,
      'PRE_OPERATIVE' || 'PREOPERATIVE' => InvestmentType.PRE_OPERATIVE,
      _ => InvestmentType.FIXED_ASSET,
    };
  }
}

class InvestmentItemModel {
  const InvestmentItemModel({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
  });

  final String id;
  final InvestmentType type;
  final String description;
  final double amount;

  factory InvestmentItemModel.fromJson(Map<String, dynamic> json) {
    final quantity = (json['quantity'] as num?)?.toDouble();
    final unitCost = (json['unitCost'] as num?)?.toDouble();
    final totalCost = (json['totalCost'] as num?)?.toDouble();

    return InvestmentItemModel(
      id: (json['id'] ?? '').toString(),
      type: InvestmentType.fromJson(
        (json['type'] ?? json['itemType'])?.toString(),
      ),
      description: (json['description'] ?? json['name'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ??
          totalCost ??
          ((quantity ?? 0) * (unitCost ?? 0)),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'description': description,
        'amount': amount,
      };
}
