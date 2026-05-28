import '../../domain/entities/module_progress.dart';

class ModuleProgressModel extends ModuleProgress {
  const ModuleProgressModel({
    required super.id,
    required super.moduleType,
    required super.status,
    required super.progressPercentage,
    super.reason,
  });

  factory ModuleProgressModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? '';
    ModuleProgressStatus parsedStatus;

    switch (statusStr.toUpperCase()) {
      case 'PENDING': parsedStatus = ModuleProgressStatus.pending; break;
      case 'IN_PROGRESS': parsedStatus = ModuleProgressStatus.inProgress; break;
      case 'COMPLETE': parsedStatus = ModuleProgressStatus.complete; break;
      case 'REQUIRES_REVISION': parsedStatus = ModuleProgressStatus.requiresRevision; break;
      case 'OUTDATED': parsedStatus = ModuleProgressStatus.outdated; break;
      default: parsedStatus = ModuleProgressStatus.unknown; break;
    }

    return ModuleProgressModel(
      id: json['id'] as int? ?? 0,
      moduleType: json['moduleType'] as String? ?? 'Modulo General',
      status: parsedStatus,
      progressPercentage: (json['progressPercentage'] as num? ?? 0).toDouble(),
      reason: json['reason'] as String?,
    );
  }
}