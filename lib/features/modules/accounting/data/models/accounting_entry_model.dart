enum AccountingStatus { current, outdated }

class AccountingEntryModel {
  final String id;
  final String accountName;
  final String accountCode;
  final double debit;
  final double credit;
  final String description;
  final DateTime date;
  final AccountingStatus status;

  AccountingEntryModel({
    required this.id,
    required this.accountName,
    required this.accountCode,
    required this.debit,
    required this.credit,
    required this.description,
    required this.date,
    required this.status,
  });

  factory AccountingEntryModel.fromJson(Map<String, dynamic> json) {
    return AccountingEntryModel(
      id: _readString(json, ['id']),
      accountName: _readString(json, ['accountName', 'account', 'name']),
      accountCode: _readString(json, ['accountCode', 'code']),
      debit: _readDouble(json, ['debit', 'debitAmount']),
      credit: _readDouble(json, ['credit', 'creditAmount']),
      description: _readString(json, ['description', 'concept', 'detail']),
      date: _readDate(json, ['date', 'entryDate', 'createdAt', 'generatedAt']),
      status: _readString(json, ['status']) == 'OUTDATED'
          ? AccountingStatus.outdated
          : AccountingStatus.current,
    );
  }

  factory AccountingEntryModel.fromEntryLine(
    Map<String, dynamic> entry,
    Map<String, dynamic> line,
  ) {
    final entryId = _readString(entry, ['id']);
    final lineOrder = _readString(line, ['displayOrder']);

    return AccountingEntryModel(
      id: lineOrder.isEmpty ? entryId : '$entryId-$lineOrder',
      accountName: _readString(line, ['accountName', 'account', 'name']),
      accountCode: _readString(line, ['accountCode', 'code']),
      debit: _readDouble(line, ['debit', 'debitAmount']),
      credit: _readDouble(line, ['credit', 'creditAmount']),
      description: _readString(entry, ['description', 'concept', 'detail']),
      date: _readDate(entry, ['date', 'entryDate', 'createdAt', 'generatedAt']),
      status: _readString(entry, ['status']) == 'OUTDATED'
          ? AccountingStatus.outdated
          : AccountingStatus.current,
    );
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];

      if (value != null) return value.toString();
    }

    return '';
  }

  static double _readDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];

      if (value is double) return value;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
    }

    return 0.0;
  }

  static DateTime _readDate(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];

      if (value != null) {
        return DateTime.tryParse(value.toString()) ?? DateTime.now();
      }
    }

    return DateTime.now();
  }
}
