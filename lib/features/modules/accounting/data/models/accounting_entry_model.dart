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
      id: json['id'] ?? '',
      accountName: json['accountName'] ?? '',
      accountCode: json['accountCode'] ?? '',
      debit: (json['debit'] ?? 0).toDouble(),
      credit: (json['credit'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      status: json['status'] == 'OUTDATED' 
          ? AccountingStatus.outdated 
          : AccountingStatus.current,
    );
  }
}