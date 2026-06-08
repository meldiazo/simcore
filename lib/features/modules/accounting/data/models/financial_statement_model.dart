enum StatementType { incomeStatement, balanceSheet, cashFlow, ratios }

class FinancialStatementModel {
  final String id;
  final String companyId;
  final StatementType type;
  final Map<String, dynamic> data; 
  final DateTime generatedAt;

  FinancialStatementModel({
    required this.id,
    required this.companyId,
    required this.type,
    required this.data,
    required this.generatedAt,
  });

  factory FinancialStatementModel.fromJson(Map<String, dynamic> json) {
    return FinancialStatementModel(
      id: json['id'] ?? '',
      companyId: json['companyId'] ?? '',
      type: _parseStatementType(json['statementType']),
      data: json['data'] ?? {},
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }

  static StatementType _parseStatementType(String? type) {
    switch (type) {
      case 'INCOME_STATEMENT':
        return StatementType.incomeStatement;
      case 'BALANCE_SHEET':
        return StatementType.balanceSheet;
      case 'CASH_FLOW':
        return StatementType.cashFlow;
      case 'RATIOS':
        return StatementType.ratios;
      default:
        return StatementType.incomeStatement;
    }
  }
}