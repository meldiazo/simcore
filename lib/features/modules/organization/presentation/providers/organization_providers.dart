import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/modules/organization/data/datasources/organization_remote_datasource.dart';
import 'package:simcore_frontend/features/modules/organization/data/models/organization_area_model.dart';
import 'package:simcore_frontend/features/modules/organization/data/models/organization_summary_model.dart';
import 'package:simcore_frontend/features/modules/organization/data/repositories/organization_repository_impl.dart';
import 'package:simcore_frontend/features/modules/organization/domain/entities/organization_area.dart';
import 'package:simcore_frontend/features/simulation/company/presentation/providers/company_providers.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_providers.dart'
    as global_providers;

final organizationRemoteDataSourceProvider =
    Provider<OrganizationRemoteDataSource>((ref) {
  return OrganizationRemoteDataSource(
    ref.watch(simulationApiClientProvider),
  );
});

final organizationSummaryProvider = FutureProvider<OrganizationSummary>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;

  if (ctx == null || ctx.companyId <= 0) {
    return Future.value(
      const OrganizationSummary(
        companyId: 0,
        areas: [],
        positions: [],
        monthlyPersonnelCost: 0,
        estimatedMonthlyCapacity: 0,
        projectedMonthlyDemand: 0,
        warnings: [
          'No hay empresa activa. Primero selecciona o carga una empresa desde el contexto de simulación.',
        ],
      ),
    );
  }

  return ref.watch(organizationRemoteDataSourceProvider).getSummary(
        companyId: ctx.companyId,
        scenarioType: 'PROBABLE',
      );
});

class OrganizationNotifier extends StateNotifier<AsyncValue<void>> {
  OrganizationNotifier(this._ds, this._ref)
      : super(const AsyncValue.data(null));

  final OrganizationRemoteDataSource _ds;
  final Ref _ref;

  int get _companyId =>
      _ref.read(simulationContextNotifierProvider).context?.companyId ?? 0;

  Future<void> createArea(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();

    try {
      await _ds.createArea(
        companyId: _companyId,
        data: data,
      );

      _invalidateOrganization();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateArea(int areaId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();

    try {
      await _ds.updateArea(
        companyId: _companyId,
        areaId: areaId,
        data: data,
      );

      _invalidateOrganization();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createPosition(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();

    try {
      await _ds.createPosition(
        companyId: _companyId,
        data: data,
      );

      _invalidateOrganization();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updatePosition(int positionId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();

    try {
      await _ds.updatePosition(
        companyId: _companyId,
        positionId: positionId,
        data: data,
      );

      _invalidateOrganization();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deletePosition(int positionId) async {
    state = const AsyncValue.loading();

    try {
      await _ds.deletePosition(
        companyId: _companyId,
        positionId: positionId,
      );

      _invalidateOrganization();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completeModule() async {
    state = const AsyncValue.loading();

    try {
      await _ds.completeModule(companyId: _companyId);

      _ref.invalidate(companyModuleProgressProvider);
      _ref.invalidate(global_providers.moduleProgressProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _invalidateOrganization() {
    _ref.invalidate(organizationSummaryProvider);
  }
}

final organizationNotifierProvider =
    StateNotifierProvider.autoDispose<OrganizationNotifier, AsyncValue<void>>(
  (ref) => OrganizationNotifier(
    ref.watch(organizationRemoteDataSourceProvider),
    ref,
  ),
);

/// Clase legacy conservada para que no rompan widgets antiguos que todavía usan
/// package:provider. La pantalla principal ya usa Riverpod.
class OrganizationProvider extends ChangeNotifier {
  OrganizationProvider({
    required this.repository,
    required this.companyId,
  });

  final OrganizationRepositoryImpl repository;
  final String companyId;

  OrganizationSummaryModel? summary;
  bool isLoading = false;

  bool get isCapacitySufficient {
    final current = summary;
    if (current == null) return false;
    return current.totalCapacity >= current.projectedDemand;
  }

  Future<void> loadOrganization(double marketDemand) async {
    isLoading = true;
    notifyListeners();

    try {
      final areas = await repository.getOrganization(companyId);

      summary = OrganizationSummaryModel(
        areas: areas,
        projectedDemand: marketDemand,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> confirmOrganizationStructure() {
    return repository.completeModule(companyId);
  }

  Future<void> createArea(OrganizationAreaModel area) async {
    await repository.createArea(companyId, area);
    await loadOrganization(summary?.projectedDemand ?? 0);
  }
}