import 'dart:convert';

enum StatementType { incomeStatement, balanceSheet, cashFlow, ratios }

class FinancialStatementModel {
  final String id;
  final String companyId;
  final StatementType type;
  final Map<String, dynamic> data;
  final List<Map<String, dynamic>> entries;
  final DateTime generatedAt;

  FinancialStatementModel({
    required this.id,
    required this.companyId,
    required this.type,
    required this.data,
    required this.entries,
    required this.generatedAt,
  });

  factory FinancialStatementModel.fromJson(Map<String, dynamic> json) {
    return FinancialStatementModel(
      id: json['id']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      type: _parseStatementType(
        json['statementType']?.toString() ?? json['type']?.toString(),
      ),
      data: _parseData(json['data'] ?? json['statementData'] ?? json['values']),
      entries: _parseEntries(json['entries']),
      generatedAt: _parseDate(json['generatedAt'] ?? json['createdAt']),
    );
  }

  static Map<String, dynamic> _parseData(dynamic rawData) {
    if (rawData == null) return <String, dynamic>{};

    if (rawData is Map<String, dynamic>) {
      return rawData;
    }

    if (rawData is Map) {
      return Map<String, dynamic>.from(rawData);
    }

    if (rawData is String) {
      final text = rawData.trim();

      if (text.isEmpty) return <String, dynamic>{};

      try {
        final decoded = jsonDecode(text);

        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }

        return <String, dynamic>{
          'value': decoded,
        };
      } catch (_) {
        return <String, dynamic>{
          'raw': rawData,
        };
      }
    }

    return <String, dynamic>{
      'value': rawData.toString(),
    };
  }

  static List<Map<String, dynamic>> _parseEntries(dynamic rawEntries) {
    if (rawEntries is! List) return const [];

    return rawEntries
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
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
