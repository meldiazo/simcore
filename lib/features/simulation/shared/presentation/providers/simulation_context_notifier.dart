import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/config/app_config.dart';
import 'package:simcore_frontend/features/auth/presentation/providers/auth_notifier.dart';
import 'package:simcore_frontend/features/simulation/shared/data/models/simulation_context_model.dart';
import 'package:simcore_frontend/features/simulation/shared/domain/entities/simulation_context.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_providers.dart';

enum SimulationContextStatus { initial, loading, needsGroupId, ready, error }

class SimulationContextState {
  const SimulationContextState({
    this.status = SimulationContextStatus.initial,
    this.context,
    this.errorMessage,
  });

  final SimulationContextStatus status;
  final SimulationContext? context;
  final String? errorMessage;

  bool get isReady => status == SimulationContextStatus.ready;
  bool get needsGroupId => status == SimulationContextStatus.needsGroupId;

  Object? get currentCompany => null;

  SimulationContextState copyWith({
    SimulationContextStatus? status,
    SimulationContext? context,
    String? errorMessage,
  }) {
    return SimulationContextState(
      status: status ?? this.status,
      context: context ?? this.context,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SimulationContextNotifier
    extends StateNotifier<SimulationContextState> {
  SimulationContextNotifier(this._ref)
      : super(const SimulationContextState()) {
    _bootstrap();
  }

  final Ref _ref;

  Future<void> _bootstrap() async {
    final config = _ref.read(appConfigProvider);

    if (config.useMockData) {
      state = SimulationContextState(
        status: SimulationContextStatus.ready,
        context: SimulationContextModel.devDefault(),
      );
      return;
    }

    final authState = _ref.read(authNotifierProvider);
    final user = authState.user;

    // ADMIN y DOCENTE usan companyId desde env (para gestión global)
    if (user != null && (user.isAdmin || user.isDocente)) {
      const companyId = int.fromEnvironment('COMPANY_ID', defaultValue: 0);
      if (companyId > 0) {
        await load(companyId: companyId);
        return;
      }
      // Sin COMPANY_ID configurado: admin/docente no necesita contexto de empresa
      state = const SimulationContextState(
        status: SimulationContextStatus.needsGroupId,
      );
      return;
    }

    // ESTUDIANTE: si ya tiene un groupId asignado, cargarlo automáticamente
    if (user != null && user.groupId != null && user.groupId! > 0) {
      await loadByGroupId(groupId: user.groupId!);
      return;
    }

    state = const SimulationContextState(
      status: SimulationContextStatus.needsGroupId,
    );
  }

  Future<void> load({required int companyId}) async {
    state = state.copyWith(status: SimulationContextStatus.loading);

    try {
      final repo = _ref.read(simulationRepositoryProvider);
      final context = await repo.getSimulationContext(companyId: companyId);
      state = SimulationContextState(
        status: SimulationContextStatus.ready,
        context: context,
      );
    } catch (e) {
      state = SimulationContextState(
        status: SimulationContextStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadByGroupId({required int groupId}) async {
    state = state.copyWith(status: SimulationContextStatus.loading);

    try {
      final repo = _ref.read(simulationRepositoryProvider);
      final context = await repo.getSimulationContextByGroupId(groupId: groupId);
      state = SimulationContextState(
        status: SimulationContextStatus.ready,
        context: context,
      );
    } catch (e) {
      state = SimulationContextState(
        status: SimulationContextStatus.needsGroupId,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() => state = const SimulationContextState();
}

final simulationContextNotifierProvider =
    StateNotifierProvider<SimulationContextNotifier, SimulationContextState>(
  (ref) => SimulationContextNotifier(ref),
);

final currentCompanyIdProvider = Provider<int>((ref) {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) {
    throw StateError(
      'SimulationContext no inicializado. '
      'Verifica que simulationContextNotifierProvider esté ready.',
    );
  }
  return ctx.companyId;
});
