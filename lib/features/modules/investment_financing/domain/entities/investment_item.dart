import 'package:simcore_frontend/core/domain/simcore_enums.dart';

class InvestmentItem {
  const InvestmentItem({
    required this.id,
    required this.companyId,
    required this.itemType,
    required this.name,
    required this.quantity,
    required this.unitCost,
    required this.totalCost,
    this.usefulLifeYears,
  });

  final int id;
  final int companyId;
  final InvestmentItemType itemType;
  final String name;
  final int quantity;
  final double unitCost;
  final double totalCost;
  final int? usefulLifeYears;
}

class InvestmentSummary {
  const InvestmentSummary({
    required this.companyId,
    required this.items,
    required this.totalFixedAssets,
    required this.totalWorkingCapital,
    required this.totalPreOperative,
    required this.grandTotal,
    required this.hasMinimumData,
  });

  final int companyId;
  final List<InvestmentItem> items;
  final double totalFixedAssets;
  final double totalWorkingCapital;
  final double totalPreOperative;
  final double grandTotal;
  final bool hasMinimumData;
}
