import 'package:simcore_frontend/core/domain/simcore_enums.dart';

class FinancingOption {
  const FinancingOption({
    required this.id,
    required this.companyId,
    required this.sourceName,
    required this.sourceType,
    required this.principalAmount,
    required this.annualInterestRate,
    required this.termMonths,
    this.isSelected = false,
  });

  final int id;
  final int companyId;
  final String sourceName;
  final FinancingSourceType sourceType;
  final double principalAmount;
  final double annualInterestRate;
  final int termMonths;
  final bool isSelected;
}

class FinancingSummary {
  const FinancingSummary({
    required this.companyId,
    required this.options,
    this.selectedOption,
    required this.totalPrincipal,
    required this.hasMinimumData,
    required this.hasSelectedOption,
  });

  final int companyId;
  final List<FinancingOption> options;
  final FinancingOption? selectedOption;
  final double totalPrincipal;
  final bool hasMinimumData;
  final bool hasSelectedOption;
}
