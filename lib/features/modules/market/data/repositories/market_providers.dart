import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/modules/market/data/datasources/market_remote_datasource.dart';
import 'package:simcore_frontend/features/modules/market/data/models/market_assumption_model.dart';
import 'package:simcore_frontend/features/modules/market/data/models/sales_projection_model.dart';
import 'package:simcore_frontend/features/modules/market/data/repositories/market_repository_impl.dart';
import 'package:simcore_frontend/features/modules/market/domain/entities/repositories/market_repository.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_providers.dart'
    as global_providers;

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
  final companyId = ref.watch(currentCompanyIdProvider);
  final repository = ref.watch(marketRepositoryProvider);
  return repository.getAssumption(companyId.toString());
});

/// Provider para obtener la proyección de ventas actual de la compañía.
final salesProjectionProvider =
    FutureProvider<SalesProjectionModel?>((ref) async {
  final companyId = ref.watch(currentCompanyIdProvider);
  final repository = ref.watch(marketRepositoryProvider);
  return repository.getProjection(companyId.toString());
});

// --- Notifier para EJECUTAR acciones (POST, PUT, PATCH) ---

class MarketNotifier extends StateNotifier<AsyncValue<void>> {
  final MarketRepository _repository;
  final String _companyId;
  final Ref _ref;

  MarketNotifier(this._repository, this._companyId, this._ref)
      : super(const AsyncValue.data(null));

  /// Guarda o actualiza los supuestos de mercado.
  Future<bool> updateAssumption(MarketAssumptionModel assumption) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateAssumption(_companyId, assumption);
      state = const AsyncValue.data(null);
      _ref.invalidate(marketAssumptionProvider); // Refresca los datos en la UI
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Solicita al backend que genere una nueva proyección de ventas.
  Future<bool> generateProjection() async {
    state = const AsyncValue.loading();
    try {
      await _repository.generateProjection(_companyId);
      state = const AsyncValue.data(null);
      _ref.invalidate(
          salesProjectionProvider); // Refresca la proyección en la UI
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Marca el módulo de mercado como completado.
  Future<bool> completeMarketModule() async {
    state = const AsyncValue.loading();
    try {
      // Llama al método específico del repositorio de mercado
      await _repository.completeMarket(_companyId);
      state = const AsyncValue.data(null);
      // Invalida el provider global para refrescar el estado en el Sidebar
      _ref.invalidate(global_providers.moduleProgressProvider);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

final marketNotifierProvider =
    StateNotifierProvider<MarketNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(marketRepositoryProvider);
  final companyId = ref.watch(currentCompanyIdProvider).toString();
  return MarketNotifier(repository, companyId, ref);
});
