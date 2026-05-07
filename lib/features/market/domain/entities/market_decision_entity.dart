import 'package:equatable/equatable.dart';

enum MarketStrategyType {
  costLeadership,
  differentiation,
  focus,
  mixed,
}

class MarketDecisionEntity extends Equatable {
  final String id;
  final String selectedSegmentId;
  final MarketStrategyType strategyType;
  final double proposedPrice;
  final double expectedSalesVolume;
  final String valueProposition;
  final String justification;
  final DateTime decidedAt;

  const MarketDecisionEntity({
    required this.id,
    required this.selectedSegmentId,
    required this.strategyType,
    required this.proposedPrice,
    required this.expectedSalesVolume,
    required this.valueProposition,
    required this.justification,
    required this.decidedAt,
  });

  @override
  List<Object?> get props => [
        id,
        selectedSegmentId,
        strategyType,
        proposedPrice,
        expectedSalesVolume,
        valueProposition,
        justification,
        decidedAt,
      ];
}