import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/router/app_router.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/api_error_state.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/loading_state.dart';

import '../../domain/entities/module_progress.dart';
import '../providers/company_providers.dart';

class WorkspacePage extends ConsumerWidget {
  const WorkspacePage({super.key});

  void _onModuleTap(BuildContext context, ModuleProgress module) {
    if (module.status == ModuleProgressStatus.requiresRevision) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Requiere revisión: ${module.reason ?? "Consulte con el docente."}')),
      );
      return;
    }
    if (module.status == ModuleProgressStatus.pending) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Módulo bloqueado o inactivo.')),
      );
      return;
    }

    switch (module.moduleType.toUpperCase()) {
      case 'MARKET':
        Navigator.of(context).pushReplacementNamed(AppRouter.market);
        break;
      case 'FINANCE':
        Navigator.of(context).pushReplacementNamed(AppRouter.investment);
        break;
      case 'ORGANIZATION':
        Navigator.of(context).pushReplacementNamed(AppRouter.organization);
        break;
      case 'ACCOUNTING':
        Navigator.of(context).pushReplacementNamed(AppRouter.accounting);
        break;
      default:
        Navigator.of(context).pushReplacementNamed(AppRouter.decisions);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceAsync = ref.watch(companyWorkspaceProvider);

    return workspaceAsync.when(
      loading: () => const LoadingState(message: 'Cargando workspace corporativo...'),
      error: (error, _) => ApiErrorState(
        title: 'No se pudo cargar el workspace',
        message: error.toString(),
        onRetry: () => ref.invalidate(companyWorkspaceProvider),
      ),
      data: (data) {
        final completedModules = data.modules
            .where((m) => m.status == ModuleProgressStatus.complete)
            .length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageIntro(
              title: 'Workspace Ejecutivo',
              subtitle: 'Panel de control real y estado de simulación',
            ),
            const SizedBox(height: 28),
            GlassPanel(
              padding: const EdgeInsets.all(28),
              backgroundColor: Colors.white.withOpacity(0.78),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: SimcoreColors.accent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          data.scenario.name.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12),
                        ),
                      ),
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 10, color: SimcoreColors.success),
                          SizedBox(width: 8),
                          Text('Conexión Activa (Real)',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Escenario: ${data.scenario.description}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "Compañía: ${data.company.name} | Has completado $completedModules de ${data.modules.length} módulos.",
                    style: const TextStyle(
                        fontSize: 15,
                        color: SimcoreColors.textSecondary,
                        height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            ResponsiveSectionWrap(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Incoherencias Detectadas'),
                      const SizedBox(height: 14),
                      if (data.incoherences.isEmpty)
                        const Text('No hay incoherencias en este ciclo.',
                            style: TextStyle(color: SimcoreColors.success, fontWeight: FontWeight.w600)),
                      ...data.incoherences.map((inc) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: SimcoreColors.warningSoft,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: SimcoreColors.warning.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: SimcoreColors.warning, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(inc.title, style: const TextStyle(fontWeight: FontWeight.w700, color: SimcoreColors.warning)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(inc.message, style: const TextStyle(color: SimcoreColors.textPrimary)),
                            ],
                          ),
                        ),
                      )),
                      const SizedBox(height: 28),
                      const SectionLabel('Trazabilidad Reciente'),
                      const SizedBox(height: 14),
                      if (data.decisions.isEmpty)
                        const Text('No hay decisiones registradas aún.',
                            style: TextStyle(color: SimcoreColors.textSecondary)),
                      ...data.decisions.map((dec) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassPanel(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dec.module, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: SimcoreColors.accent)),
                              const SizedBox(height: 4),
                              Text(dec.description),
                            ],
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Progreso de Módulos',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 20),
                        ...data.modules.map((module) {
                          Color statusColor;
                          switch (module.status) {
                            case ModuleProgressStatus.complete:
                              statusColor = SimcoreColors.success;
                              break;
                            case ModuleProgressStatus.inProgress:
                              statusColor = SimcoreColors.accent;
                              break;
                            case ModuleProgressStatus.requiresRevision:
                              statusColor = SimcoreColors.warning;
                              break;
                            case ModuleProgressStatus.outdated:
                              statusColor = Colors.red;
                              break;
                            case ModuleProgressStatus.pending:
                            default:
                              statusColor = SimcoreColors.textTertiary;
                              break;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              onTap: () => _onModuleTap(context, module),
                              borderRadius: BorderRadius.circular(8),
                              child: MetricBar(
                                label: '${module.moduleType} (${module.status.name})',
                                value: module.progressPercentage,
                                max: 100,
                                trailing: '${module.progressPercentage.toInt()}%',
                                color: statusColor,
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => Navigator.of(context).pushReplacementNamed(AppRouter.decisions),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('Centro de Decisiones'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}