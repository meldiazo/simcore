import 'package:equatable/equatable.dart';

enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

class AlertEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime createdAt;
  final bool isResolved;

  const AlertEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.createdAt,
    this.isResolved = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        severity,
        createdAt,
        isResolved,
      ];
}