import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/modules/market/data/models/market_assumption_model.dart';
import 'package:simcore_frontend/features/modules/market/data/repositories/market_providers.dart';
import 'package:simcore_frontend/features/modules/market/presentation/pages/market_assumption_form.dart';
import 'package:simcore_frontend/features/modules/market/presentation/pages/sales_projection_panel.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/models/decision_model.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/repositories/decision_providers.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';
import 'package:simcore_frontend/features/simulation/module_progress/presentation/providers/module_progress_providers.dart' as module_actions;
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_providers.dart' as global_providers;
import 'package:simcore_frontend/features/modules/investment_financing/presentation/providers/investment_financing_providers.dart';
import 'package:simcore_frontend/features/simulation/company/presentation/providers/company_providers.dart' as company_providers;

class MarketPage extends ConsumerStatefulWidget {
  const MarketPage({super.key});

  @override
  ConsumerState<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends ConsumerState<MarketPage> {
  bool _hasStarted = false;
  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveAssumptions(MarketAssumptionModel assumption) async {
    final success = await ref.read(marketNotifierProvider.notifier).updateAssumption(assumption);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supuestos de mercado guardados.'), backgroundColor: SimcoreColors.success),
      );

      final decision = DecisionModel(
        id: '', // El backend lo genera
        companyId: ref.read(currentCompanyIdProvider).toString(),
        module: SimModule.market.toApi(),
        decisionType: 'MARKET_ASSUMPTION',
        payload: assumption.toJson(),
        justification: assumption.commercialJustification,
      );
      ref.read(decisionNotifierProvider.notifier).createDecision(decision);

    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar los supuestos.'), backgroundColor: SimcoreColors.danger),
      );
    }
  }

  Future<void> _generateProjection() async {
    final success = await ref.read(marketNotifierProvider.notifier).generateProjection();
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proyección de ventas generada.'), backgroundColor: SimcoreColors.accent),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al generar la proyección.'), backgroundColor: SimcoreColors.danger),
      );
    }
  }

  Future<void> _completeModule() async {
  final companyId = ref.read(currentCompanyIdProvider).toString();

  try {
    // 1. FORZAMOS EL INICIO explícitamente antes de completar
    // Esto asegura que el estado del servidor cambie a EN_PROGRESO
    await ref.read(module_actions.moduleProgressProvider.notifier).start(
          companyId,
          SimModule.market.toApi(),
        );
    
    // Pequeño delay de 300ms para dar tiempo al servidor a procesar el cambio de estado
    await Future.delayed(const Duration(milliseconds: 300));

    // 2. AHORA SÍ, COMPLETAMOS EL MÓDULO
    final success =
        await ref.read(marketNotifierProvider.notifier).completeMarketModule();

    if (mounted && success) {
      // Invalida estados para refrescar UI
      ref.invalidate(company_providers.companyModuleProgressProvider);
      ref.invalidate(company_providers.companyWorkspaceProvider);
      ref.invalidate(global_providers.moduleProgressProvider);
      ref.invalidate(investmentFinancingProvider(companyId));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Módulo completado con éxito.'),
          backgroundColor: SimcoreColors.success,
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar: ${e.toString()}'),
          backgroundColor: SimcoreColors.danger,
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final ctxState = ref.watch(simulationContextNotifierProvider);
    if (!ctxState.isReady || ctxState.context == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_hasStarted) {
      _hasStarted = true;
      Future.microtask(() {
        ref.read(module_actions.moduleProgressProvider.notifier).start(
          ctxState.context!.companyId.toString(),
          SimModule.market.toApi(),
        );
      });
    }

    final assumptionAsync = ref.watch(marketAssumptionProvider);
    final projectionAsync = ref.watch(salesProjectionProvider);
    final marketNotifierState = ref.watch(marketNotifierProvider);

    final canComplete = assumptionAsync.hasValue &&
        assumptionAsync.value != null &&
        projectionAsync.hasValue &&
        projectionAsync.value != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageIntro(
          title: 'Módulo de Mercado',
          subtitle: 'Define tus supuestos de mercado para estimar la demanda y proyectar las ventas.',
        ),
        const SizedBox(height: 24),
        GlassPanel(
          child: MarketAssumptionForm(
            initialAssumption: assumptionAsync.value,
            isLoading: marketNotifierState.isLoading,
            onSave: _saveAssumptions,
          ),
        ),
        const SizedBox(height: 24),
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('2. Proyección de Ventas nuevo'),
              const SizedBox(height: 20),
              const SalesProjectionPanel(),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: marketNotifierState.isLoading ? null : _generateProjection,
                  icon: marketNotifierState.isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome),
                  label: const Text('Generar Proyección'),
                  style: FilledButton.styleFrom(backgroundColor: SimcoreColors.accent),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GlassPanel(
          child: ResponsiveHeaderAction(
            title: 'Finalizar Módulo de Mercado',
            subtitle: 'Al completar, tus supuestos y proyecciones se considerarán finales para este ciclo.',
            action: FilledButton.icon(
              onPressed: canComplete ? _completeModule : null,
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Completar Módulo'),
              style: FilledButton.styleFrom(backgroundColor: SimcoreColors.success),
            ),
          ),
        ),
      ],
    );
  }
}