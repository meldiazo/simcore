import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/modules/market/data/datasources/market_remote_datasource.dart';
import 'package:simcore_frontend/features/modules/market/data/models/market_assumption_model.dart';
import 'package:simcore_frontend/features/modules/market/data/models/sales_projection_model.dart';
import 'package:simcore_frontend/features/modules/market/data/repositories/market_repository_impl.dart';
import 'package:simcore_frontend/features/modules/market/domain/entities/repositories/market_repository.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/scenario_context_provider.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_providers.dart'
    as global_providers;
import 'package:simcore_frontend/features/simulation/company/presentation/providers/company_providers.dart'
    as company_providers;

// 1. Inyección del Datasource
final marketRemoteDatasourceProvider = Provider<MarketRemoteDatasource>((ref) {
  return MarketRemoteDatasource(ref.watch(simulationApiClientProvider));
});

// 2. Inyección del Repositorio
final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  final datasource = ref.watch(marketRemoteDatasourceProvider);
  return MarketRepositoryImpl(remoteDatasource: datasource);
});

// --- Providers para LEER datos (GET) ---

/// Provider para obtener los supuestos de mercado actuales de la compañía.
final marketAssumptionProvider =
    FutureProvider<MarketAssumptionModel?>((ref) async {
  final ctxState = ref.watch(simulationContextNotifierProvider);
  if (ctxState.context == null) {
    return null; // Espera pacientemente si no ha cargado
  }

  final companyId = ctxState.context!.companyId;
  final repository = ref.watch(marketRepositoryProvider);
  return repository.getAssumption(companyId.toString());
});

/// Provider para obtener la proyección de ventas actual de la compañía.
final salesProjectionProvider =
    FutureProvider<SalesProjectionModel?>((ref) async {
  final ctxState = ref.watch(simulationContextNotifierProvider);
  if (ctxState.context == null) {
    return null; // Espera pacientemente si no ha cargado
  }

  final companyId = ctxState.context!.companyId;
  final repository = ref.watch(marketRepositoryProvider);
  return repository.getProjection(companyId.toString());
});

// --- Notifier para EJECUTAR acciones (POST, PUT, PATCH) ---

class MarketNotifier extends StateNotifier<AsyncValue<void>> {
  final MarketRepository _repository;
  final Ref _ref;

  MarketNotifier(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  // Helper para obtener el ID en el momento exacto del clic
  String get _companyId => _ref.read(currentCompanyIdProvider).toString();

  /// Guarda o actualiza los supuestos de mercado.
  Future<bool> updateAssumption(MarketAssumptionModel assumption) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateAssumption(_companyId, assumption);
      if (!mounted) return false;
      state = const AsyncValue.data(null);
      _ref.invalidate(marketAssumptionProvider);
      return true;
    } catch (e, stack) {
      if (!mounted) return false;
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Solicita al backend que genere una nueva proyección de ventas.
  Future<bool> generateProjection() async {
    state = const AsyncValue.loading();
    try {
      await _repository.generateProjection(
        _companyId,
        scenarioType: _ref.read(selectedScenarioTypeProvider),
      );
      if (!mounted) return false;
      state = const AsyncValue.data(null);
      _ref.invalidate(salesProjectionProvider);
      return true;
    } catch (e, stack) {
      if (!mounted) return false;
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Marca el módulo de mercado como completado.
  Future<bool> completeMarketModule() async {
    state = const AsyncValue.loading();
    try {
      await _repository.completeMarket(_companyId);
      if (!mounted) return false;
      state = const AsyncValue.data(null);
      _ref.invalidate(global_providers.moduleProgressProvider);
      _ref.invalidate(company_providers.companyModuleProgressProvider);
      _ref.invalidate(company_providers.companyWorkspaceProvider);
      return true;
    } catch (e, stack) {
      if (!mounted) return false;
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

final marketNotifierProvider =
    StateNotifierProvider<MarketNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(marketRepositoryProvider);
  // Pasamos el ref en vez del companyId duro para que lo evalúe en tiempo real
  return MarketNotifier(repository, ref);
});
