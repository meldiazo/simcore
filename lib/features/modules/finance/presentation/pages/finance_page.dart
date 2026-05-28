import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';
import 'package:simcore_frontend/features/simulation/module_progress/presentation/providers/module_progress_providers.dart' as module_actions;
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_providers.dart' as global_providers;

class FinancePage extends ConsumerStatefulWidget {
  const FinancePage({super.key});

  @override
  ConsumerState<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends ConsumerState<FinancePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final simContextState = ref.read(simulationContextNotifierProvider);
      if (simContextState.isReady && simContextState.context != null) {
        final companyId = simContextState.context!.companyId.toString();
        ref.read(module_actions.moduleProgressProvider.notifier).start(
              companyId,
              SimModule.investment.toApi(),
            );
      }
    });
  }

  void _completeModule() {
    final simContextState = ref.read(simulationContextNotifierProvider);
    if (simContextState.isReady && simContextState.context != null) {
      final companyId = simContextState.context!.companyId.toString();

      ref.read(module_actions.moduleProgressProvider.notifier).complete(
            companyId,
            SimModule.investment.toApi(),
          );

      ref.invalidate(global_providers.moduleProgressProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Módulo de Financiamiento completado y estado global actualizado.'),
          backgroundColor: SimcoreColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageIntro(
          title: 'Inversiones y Financiamiento',
          subtitle: 'Define la estrategia de capital de la empresa, gestionando activos y pasivos para maximizar el valor.',
        ),
        const SizedBox(height: 24),
        GlassPanel(
          child: ResponsiveHeaderAction(
            title: 'Confirmar Decisiones Financieras',
            subtitle: 'Al confirmar, tus decisiones de inversión y financiamiento se guardarán y el estado del módulo se actualizará a "Completo".',
            action: FilledButton.icon(
              onPressed: _completeModule,
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Confirmar y Completar'),
            ),
          ),
        ),
      ],
    );
  }
}