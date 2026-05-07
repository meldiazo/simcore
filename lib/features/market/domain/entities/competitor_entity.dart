import 'package:equatable/equatable.dart';

class CompetitorEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double marketShare;
  final double priceLevel;
  final String strengths;
  final String weaknesses;
  final String differentiationStrategy;

  const CompetitorEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.marketShare,
    required this.priceLevel,
    required this.strengths,
    required this.weaknesses,
    required this.differentiationStrategy,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        marketShare,
        priceLevel,
        strengths,
        weaknesses,
        differentiationStrategy,
      ];
}