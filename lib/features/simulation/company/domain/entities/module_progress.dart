import 'package:equatable/equatable.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';

class CompanyModuleProgress extends Equatable {
  const CompanyModuleProgress({
    required this.module,
    required this.status,
    required this.progress,
    this.revisionReason,
    this.updatedAt,
  });

  final SimModule module;
  final ModuleStatus status;
  final int progress;
  final String? revisionReason;
  final String? updatedAt;

  String get name => module.label;

  bool get isUnlocked =>
      status != ModuleStatus.pending;

  @override
  List<Object?> get props =>
      [module, status, progress, revisionReason, updatedAt];
}
