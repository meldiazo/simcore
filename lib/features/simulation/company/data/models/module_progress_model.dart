import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/simulation/company/domain/entities/module_progress.dart';

class CompanyModuleProgressModel extends CompanyModuleProgress {
  const CompanyModuleProgressModel({
    required super.module,
    required super.status,
    required super.progress,
    super.revisionReason,
    super.updatedAt,
  });

  factory CompanyModuleProgressModel.fromJson(Map<String, dynamic> json) {
    final moduleValue = _readString(json, ['module', 'id', 'moduleId', 'moduleCode', 'code']);
    final statusValue = _readString(json, ['status', 'state']);

    final module = SimModule.fromApi(moduleValue);
    final status = ModuleStatus.fromApi(statusValue);

    final rawProgress = _readInt(json, ['progress', 'completionPercentage', 'percentage']);
    final progress = rawProgress > 0 ? rawProgress : status.progressHint;

    final revisionReason = json['revisionReason']?.toString() ??
        json['teacherComment']?.toString() ??
        json['comment']?.toString();

    return CompanyModuleProgressModel(
      module: module,
      status: status,
      progress: progress,
      revisionReason: status == ModuleStatus.requiresRevision ? revisionReason : null,
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v != null) return v.toString();
    }
    return '';
  }

  static int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is int) return v;
      if (v is double) return v.round();
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
    }
    return 0;
  }
}
