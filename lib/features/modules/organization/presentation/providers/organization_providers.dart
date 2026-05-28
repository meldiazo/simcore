import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/modules/organization/data/datasources/organization_remote_datasource.dart';
import 'package:simcore_frontend/features/modules/organization/domain/entities/organization_area.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

final organizationRemoteDataSourceProvider = Provider<OrganizationRemoteDataSource>((ref) {
  return OrganizationRemoteDataSource(ref.watch(simulationApiClientProvider));
});

final organizationSummaryProvider = FutureProvider<OrganizationSummary>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) {
    return Future.value(OrganizationSummary(
      companyId: 0,
      areas: const [],
      positions: const [],
      monthlyPersonnelCost: 0,
      estimatedMonthlyCapacity: 0,
      projectedMonthlyDemand: 0,
      warnings: const [],
    ));
  }
  return ref
      .watch(organizationRemoteDataSourceProvider)
      .getSummary(companyId: ctx.companyId);
});

class OrganizationNotifier extends StateNotifier<AsyncValue<void>> {
  OrganizationNotifier(this._ds, this._ref) : super(const AsyncValue.data(null));

  final OrganizationRemoteDataSource _ds;
  final Ref _ref;

  int get _companyId =>
      _ref.read(simulationContextNotifierProvider).context?.companyId ?? 0;

  Future<void> createArea(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _ds.createArea(companyId: _companyId, data: data);
      _ref.invalidate(organizationSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateArea(int areaId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _ds.updateArea(companyId: _companyId, areaId: areaId, data: data);
      _ref.invalidate(organizationSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createPosition(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _ds.createPosition(companyId: _companyId, data: data);
      _ref.invalidate(organizationSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updatePosition(int positionId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _ds.updatePosition(companyId: _companyId, positionId: positionId, data: data);
      _ref.invalidate(organizationSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deletePosition(int positionId) async {
    state = const AsyncValue.loading();
    try {
      await _ds.deletePosition(companyId: _companyId, positionId: positionId);
      _ref.invalidate(organizationSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completeModule() async {
    state = const AsyncValue.loading();
    try {
      await _ds.completeModule(companyId: _companyId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final organizationNotifierProvider =
    StateNotifierProvider.autoDispose<OrganizationNotifier, AsyncValue<void>>(
  (ref) => OrganizationNotifier(
    ref.watch(organizationRemoteDataSourceProvider),
    ref,
  ),
);
