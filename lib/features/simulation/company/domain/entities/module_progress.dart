enum ModuleProgressStatus {
  pending,
  inProgress,
  complete,
  requiresRevision,
  outdated,
  unknown
}

class ModuleProgress {
  final int id;
  final String moduleType;
  final ModuleProgressStatus status;
  final double progressPercentage;
  final String? reason;

  const ModuleProgress({
    required this.id,
    required this.moduleType,
    required this.status,
    required this.progressPercentage,
    this.reason,
  });
}