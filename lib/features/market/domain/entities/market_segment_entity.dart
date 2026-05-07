import 'package:equatable/equatable.dart';

class MarketSegmentEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String customerProfile;
  final int estimatedCustomers;
  final double estimatedDemand;
  final double growthRate;
  final double attractivenessScore;

  const MarketSegmentEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.customerProfile,
    required this.estimatedCustomers,
    required this.estimatedDemand,
    required this.growthRate,
    required this.attractivenessScore,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        customerProfile,
        estimatedCustomers,
        estimatedDemand,
        growthRate,
        attractivenessScore,
      ];
}