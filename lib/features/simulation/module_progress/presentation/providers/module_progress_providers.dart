import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/simulation/company/presentation/providers/company_providers.dart';
import 'package:simcore_frontend/features/simulation/module_progress/data/datasources/module_progress_remote_datasource.dart';

final moduleProgressRemoteDataSourceProvider =
    Provider<ModuleProgressRemoteDataSource>((ref) {
  return ModuleProgressRemoteDataSource(ref.watch(simulationApiClientProvider));
});

class ModuleProgressNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  ModuleProgressNotifier(this._ds, this._ref) : super(const AsyncValue.data(null));

  final ModuleProgressRemoteDataSource _ds;
  final Ref _ref;

  Future<void> startModule(int companyId, String module) async {
    state = const AsyncValue.loading();
    try {
      final result = await _ds.startModule(companyId: companyId, module: module);
      state = AsyncValue.data(result);
      _ref.invalidate(companyModuleProgressProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completeModule(int companyId, String module) async {
    state = const AsyncValue.loading();
    try {
      final result = await _ds.completeModule(companyId: companyId, module: module);
      state = AsyncValue.data(result);
      _ref.invalidate(companyModuleProgressProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> lockModule(int companyId, String module, bool locked) async {
    state = const AsyncValue.loading();
    try {
      final result = await _ds.lockModule(companyId: companyId, module: module, locked: locked);
      state = AsyncValue.data(result);
      _ref.invalidate(companyModuleProgressProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markRequiresRevision(int companyId, String module, String message) async {
    state = const AsyncValue.loading();
    try {
      final result = await _ds.markRequiresRevision(
        companyId: companyId,
        module: module,
        message: message,
      );
      state = AsyncValue.data(result);
      _ref.invalidate(companyModuleProgressProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final moduleProgressNotifierProvider = StateNotifierProvider.autoDispose<
    ModuleProgressNotifier, AsyncValue<Map<String, dynamic>?>>(
  (ref) => ModuleProgressNotifier(
    ref.watch(moduleProgressRemoteDataSourceProvider),
    ref,
  ),
);
