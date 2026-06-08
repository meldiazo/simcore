import 'package:simcore_frontend/features/simulation/module_progress/domain/repositories/module_progress_repository.dart';

import '../datasources/module_progress_remote_datasource.dart';
import '../models/module_progress_model.dart';

class ModuleProgressRepositoryImpl implements ModuleProgressRepository {
  final ModuleProgressRemoteDatasource remoteDatasource;

  ModuleProgressRepositoryImpl({required this.remoteDatasource});

  @override
  Future<ModuleProgressModel> startModule(String companyId, String module) async {
    final data = await remoteDatasource.patchModuleAction(companyId, module, 'start');
    return ModuleProgressModel.fromJson(data);
  }

  @override
  Future<ModuleProgressModel> completeModule(String companyId, String module) async {
    final data = await remoteDatasource.patchModuleAction(companyId, module, 'complete');
    return ModuleProgressModel.fromJson(data);
  }

  @override
  Future<ModuleProgressModel> lockModule(String companyId, String module) async {
    final data = await remoteDatasource.patchModuleAction(companyId, module, 'lock');
    return ModuleProgressModel.fromJson(data);
  }

  @override
  Future<ModuleProgressModel> markRequiresRevision(String companyId, String module) async {
    final data = await remoteDatasource.patchModuleAction(companyId, module, 'requires-revision');
    return ModuleProgressModel.fromJson(data);
  }
}