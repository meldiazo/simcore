import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/features/simulation/module_progress/presentation/pages/data/datasources/module_progress_remote_datasource.dart';
import 'package:simcore_frontend/features/simulation/module_progress/presentation/pages/data/repositories/module_progress_repository_impl.dart';

import '../../domain/repositories/module_progress_repository.dart';

// 1. Inyectamos el Datasource
final moduleProgressDatasourceProvider = Provider<ModuleProgressRemoteDatasource>((ref) {
  return ModuleProgressRemoteDatasource();
});

// 2. Inyectamos el Repositorio
final moduleProgressRepositoryProvider = Provider<ModuleProgressRepository>((ref) {
  final datasource = ref.watch(moduleProgressDatasourceProvider);
  return ModuleProgressRepositoryImpl(remoteDatasource: datasource);
});

// 3. Provider para manejar el estado y las acciones en la UI
class ModuleProgressNotifier extends StateNotifier<AsyncValue<void>> {
  final ModuleProgressRepository repository;

  ModuleProgressNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> start(String companyId, String module) async {
    state = const AsyncValue.loading();
    try {
      await repository.startModule(companyId, module);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> complete(String companyId, String module) async {
    state = const AsyncValue.loading();
    try {
      await repository.completeModule(companyId, module);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> lock(String companyId, String module) async {
    state = const AsyncValue.loading();
    try {
      await repository.lockModule(companyId, module);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> requiresRevision(String companyId, String module) async {
    state = const AsyncValue.loading();
    try {
      await repository.markRequiresRevision(companyId, module);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final moduleProgressProvider = StateNotifierProvider<ModuleProgressNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(moduleProgressRepositoryProvider);
  return ModuleProgressNotifier(repository);
});