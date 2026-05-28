
import 'package:simcore_frontend/features/simulation/module_progress/presentation/pages/data/models/module_progress_model.dart';

abstract class ModuleProgressRepository {
  Future<ModuleProgressModel> startModule(String companyId, String module);
  Future<ModuleProgressModel> completeModule(String companyId, String module);
  Future<ModuleProgressModel> lockModule(String companyId, String module);
  Future<ModuleProgressModel> markRequiresRevision(String companyId, String module);
}