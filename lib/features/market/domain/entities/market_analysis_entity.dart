import 'package:equatable/equatable.dart';

import 'alert_entity.dart';
import 'competitor_entity.dart';
import 'kpi_entity.dart';
import 'market_decision_entity.dart';
import 'market_segment_entity.dart';

class MarketAnalysisEntity extends Equatable {
  final String id;
  final String simulationId;
  final String businessIdea;
  final String marketProblem;
  final String targetMarket;
  final double estimatedMarketSize;
  final double estimatedAnnualDemand;
  final double averageMarketPrice;
  final List<MarketSegmentEntity> segments;
  final List<CompetitorEntity> competitors;
  final List<KpiEntity> kpis;
  final List<AlertEntity> alerts;
  final MarketDecisionEntity? decision;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MarketAnalysisEntity({
    required this.id,
    required this.simulationId,
    required this.businessIdea,
    required this.marketProblem,
    required this.targetMarket,
    required this.estimatedMarketSize,
    required this.estimatedAnnualDemand,
    required this.averageMarketPrice,
    required this.segments,
    required this.competitors,
    required this.kpis,
    required this.alerts,
    this.decision,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        simulationId,
        businessIdea,
        marketProblem,
        targetMarket,
        estimatedMarketSize,
        estimatedAnnualDemand,
        averageMarketPrice,
        segments,
        competitors,
        kpis,
        alerts,
        decision,
        createdAt,
        updatedAt,
      ];
}