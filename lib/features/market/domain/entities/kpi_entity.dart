import 'package:equatable/equatable.dart';

class KpiEntity extends Equatable {
  final String id;
  final String name;
  final double value;
  final String unit;
  final String description;
  final double? targetValue;
  final DateTime? calculatedAt;

  const KpiEntity({
    required this.id,
    required this.name,
    required this.value,
    required this.unit,
    required this.description,
    this.targetValue,
    this.calculatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        value,
        unit,
        description,
        targetValue,
        calculatedAt,
      ];
}