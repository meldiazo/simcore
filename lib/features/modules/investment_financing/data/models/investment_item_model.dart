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
    final quantity = _readDouble(json, 'quantity');
    final unitCost = _readDouble(json, 'unitCost');
    final backendTotal =
        _readDouble(json, 'total') ?? _readDouble(json, 'totalCost');

    final description = _readString(json, 'description');
    final name = _readString(json, 'name');

    return InvestmentItemModel(
      id: (json['id'] ?? '').toString(),
      type: InvestmentType.fromJson(
        (json['type'] ?? json['itemType'])?.toString(),
      ),
      description: description.isNotEmpty ? description : name,
      amount: _readDouble(json, 'amount') ??
          backendTotal ??
          ((quantity ?? 0) * (unitCost ?? 0)),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'description': description,
        'amount': amount,
      };

  static double? _readDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static String _readString(Map<String, dynamic> json, String key) {
    return (json[key] ?? '').toString().trim();
  }
}