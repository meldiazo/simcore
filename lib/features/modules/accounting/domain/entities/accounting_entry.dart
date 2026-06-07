class AccountingEntryLine {
  const AccountingEntryLine({
    required this.accountCode,
    required this.accountName,
    required this.debit,
    required this.credit,
  });

  final String accountCode;
  final String accountName;
  final double debit;
  final double credit;
}

class AccountingEntry {
  const AccountingEntry({
    required this.id,
    required this.companyId,
    required this.scenarioType,
    required this.sourceModule,
    required this.entryType,
    required this.status,
    required this.periodLabel,
    required this.description,
    this.lines = const [],
  });

  final int id;
  final int companyId;
  final String scenarioType;
  final String sourceModule;
  final String entryType;
  final String status;
  final String periodLabel;
  final String description;
  final List<AccountingEntryLine> lines;
}

class FinancialStatementLine {
  const FinancialStatementLine({
    required this.label,
    required this.amount,
    this.isTotal = false,
  });

  final String label;
  final double amount;
  final bool isTotal;
}

class FinancialStatement {
  const FinancialStatement({
    required this.id,
    required this.companyId,
    required this.scenarioType,
    required this.statementType,
    required this.periodLabel,
    required this.status,
    this.lines = const [],
  });

  final int id;
  final int companyId;
  final String scenarioType;
  final String statementType;
  final String periodLabel;
  final String status;
  final List<FinancialStatementLine> lines;
}
