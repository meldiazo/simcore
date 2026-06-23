import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/api_error_state.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/loading_state.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/module_flow_stepper.dart';
import 'package:simcore_frontend/features/simulation/company/domain/entities/module_progress.dart';
import 'package:simcore_frontend/features/simulation/company/presentation/providers/company_providers.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';
import 'package:simcore_frontend/features/modules/analysis/presentation/providers/analysis_providers.dart';

class WorkspacePage extends ConsumerWidget {
  const WorkspacePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextState = ref.watch(simulationContextNotifierProvider);

    if (contextState.status == SimulationContextStatus.loading ||
        contextState.status == SimulationContextStatus.initial) {
      return const LoadingState(message: 'Cargando contexto de simulación...');
    }

    if (contextState.status == SimulationContextStatus.error) {
  return ApiErrorState(
    title: 'No se pudo cargar el contexto de simulación',
    message: contextState.errorMessage ?? 'Error desconocido',
    onRetry: () => ref.invalidate(simulationContextNotifierProvider),
  );
}

    final workspaceAsync = ref.watch(companyWorkspaceProvider);

    return workspaceAsync.when(
      loading: () =>
          const LoadingState(message: 'Cargando workspace de empresa...'),
      error: (error, _) => ApiErrorState(
        title: 'No se pudo cargar el workspace',
        message: error.toString(),
        onRetry: () => ref.invalidate(companyWorkspaceProvider),
      ),
      data: (workspace) => _WorkspaceBody(workspace: workspace),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _WorkspaceBody extends ConsumerWidget {
  const _WorkspaceBody({required this.workspace});

  final CompanyWorkspaceData workspace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenario = workspace.activeScenario;
    final scenarioName = scenario?['name']?.toString() ??
        scenario?['type']?.toString() ??
        'Escenario activo';
    final cycleLabel = scenario?['cycle']?.toString() ??
        scenario?['period']?.toString() ??
        'Ciclo actual';

    final indicatorsAsync = ref.watch(financialIndicatorsProvider);

    int getProgress(SimModule mod) {
      final match = workspace.modules.where((m) => m.module == mod).firstOrNull;
      return match?.progress ?? 0;
    }

    final marketP = getProgress(SimModule.market);
    final investP = getProgress(SimModule.investment);
    final orgP = getProgress(SimModule.organization);
    final accP = getProgress(SimModule.accounting);
    final analP = getProgress(SimModule.analysis);

    final stage1Progress = ((marketP + investP) / 2).round();
    final stage2Progress = ((orgP + accP) / 2).round();
    final stage3Progress = analP;

    Widget buildKpiCards() {
      return indicatorsAsync.maybeWhen(
        data: (indicators) {
          if (indicators == null || indicators.isEmpty) {
            return const SizedBox.shrink();
          }

          final van = indicators['van'] as num?;
          final tir = indicators['tir'] as num?;
          final breakEven = indicators['breakEvenMonthlyRevenue'] as num?;
          final cashFlows = indicators['cashFlows'] as List?;

          double totalRevenue = 0.0;
          if (cashFlows != null) {
            for (final flow in cashFlows) {
              if (flow is Map) {
                totalRevenue += (flow['revenue'] as num? ?? 0.0).toDouble();
              }
            }
          }

          final vanText = van != null ? '\$${van.toStringAsFixed(0)}' : '-';
          final revenueText = totalRevenue > 0 ? '\$${totalRevenue.toStringAsFixed(0)}' : '-';
          final tirText = tir != null ? '${(tir * 100).toStringAsFixed(1)}%' : '-';
          final breakEvenText = breakEven != null ? '\$${breakEven.toStringAsFixed(0)}/mes' : '-';

          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _KpiTile(
                  label: 'VAN Probable',
                  value: vanText,
                  icon: Icons.analytics_rounded,
                  color: SimcoreColors.accent,
                ),
                _KpiTile(
                  label: 'Ingresos Proyectados',
                  value: revenueText,
                  icon: Icons.trending_up_rounded,
                  color: SimcoreColors.success,
                ),
                _KpiTile(
                  label: 'TIR',
                  value: tirText,
                  icon: Icons.percent_rounded,
                  color: SimcoreColors.warning,
                ),
                _KpiTile(
                  label: 'Punto de Equilibrio',
                  value: breakEvenText,
                  icon: Icons.calculate_rounded,
                  color: Colors.blueGrey,
                ),
              ],
            ),
          );
        },
        orElse: () => const SizedBox.shrink(),
      );
    }

    Widget buildStageProgressBar() {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: GlassPanel(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.route_rounded, color: SimcoreColors.accent),
                  SizedBox(width: 8),
                  Text(
                    'Avance por Etapa',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 650;
                  final stageWidgets = [
                    _StageItem(
                      title: 'Mercado e Inversión',
                      progress: stage1Progress,
                      color: SimcoreColors.accent,
                      icon: Icons.storefront_rounded,
                    ),
                    _StageItem(
                      title: 'Estructura Operativa',
                      progress: stage2Progress,
                      color: SimcoreColors.success,
                      icon: Icons.corporate_fare_rounded,
                    ),
                    _StageItem(
                      title: 'Defensa Financiera',
                      progress: stage3Progress,
                      color: SimcoreColors.warning,
                      icon: Icons.shield_rounded,
                    ),
                  ];

                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(child: stageWidgets[0]),
                        Container(
                          width: 24,
                          height: 2,
                          color: SimcoreColors.border,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        Expanded(child: stageWidgets[1]),
                        Container(
                          width: 24,
                          height: 2,
                          color: SimcoreColors.border,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        Expanded(child: stageWidgets[2]),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        stageWidgets[0],
                        const SizedBox(height: 12),
                        stageWidgets[1],
                        const SizedBox(height: 12),
                        stageWidgets[2],
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    Widget buildSalesChart() {
      return indicatorsAsync.maybeWhen(
        data: (indicators) {
          if (indicators == null || indicators.isEmpty) {
            return const SizedBox.shrink();
          }

          final cashFlows = indicators['cashFlows'] as List?;
          if (cashFlows == null || cashFlows.isEmpty) {
            return const SizedBox.shrink();
          }

          double maxRevenue = 0.0;
          for (final flow in cashFlows) {
            if (flow is Map) {
              final rev = (flow['revenue'] as num? ?? 0.0).toDouble();
              if (rev > maxRevenue) maxRevenue = rev;
            }
          }
          if (maxRevenue == 0.0) maxRevenue = 1.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: GlassPanel(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bar_chart_rounded, color: SimcoreColors.success),
                      SizedBox(width: 8),
                      Text(
                        'Proyección de Ventas (Mensual)',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 180,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: cashFlows.map((flow) {
                        if (flow is! Map) return const SizedBox.shrink();
                        final month = (flow['period'] ?? flow['month'] ?? 0) as int;
                        final revenue = (flow['revenue'] as num? ?? 0.0).toDouble();
                        final ratio = (revenue / maxRevenue).clamp(0.02, 1.0);

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Tooltip(
                                  message: 'Mes $month: \$${revenue.toStringAsFixed(0)}',
                                  child: Container(
                                    height: 130 * ratio,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [SimcoreColors.accent, SimcoreColors.success],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: SimcoreColors.accent.withValues(alpha: 0.15),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'M$month',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: SimcoreColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        orElse: () => const SizedBox.shrink(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageIntro(
          title: 'Workspace Ejecutivo',
          subtitle: 'Panel de control — ${workspace.company.name}',
        ),
        const SizedBox(height: 28),
        buildKpiCards(),
        buildStageProgressBar(),
        buildSalesChart(),

        // ── Hero banner ──────────────────────────────────────────────────────
        GlassPanel(
          padding: const EdgeInsets.all(28),
          backgroundColor: Colors.white.withValues(alpha: 0.78),
          child: Wrap(
            spacing: 28,
            runSpacing: 28,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: SimcoreColors.accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            cycleLabel.toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12),
                          ),
                        ),
                        if (scenario != null)
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle,
                                  size: 10, color: SimcoreColors.success),
                              SizedBox(width: 8),
                              Text('Escenario activo',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(builder: (context, constraints) {
                      final headlineSize =
                          constraints.maxWidth < 380 ? 32.0 : 46.0;
                      return RichText(
                        softWrap: true,
                        text: TextSpan(
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                  fontSize: headlineSize, height: 1.08),
                          children: [
                            const TextSpan(text: 'Escenario '),
                            TextSpan(
                              text: scenarioName,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: headlineSize,
                                fontWeight: FontWeight.w700,
                                color: SimcoreColors.accent,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 14),
                    Text(
                      'Tu equipo ha completado ${workspace.completedModules} '
                      'de ${workspace.modules.length} módulos. '
                      '${workspace.incoherences.isEmpty ? 'Sin incoherencias detectadas.' : '${workspace.incoherences.length} incoherencia(s) detectada(s).'}',
                      style: const TextStyle(
                          fontSize: 15,
                          color: SimcoreColors.textSecondary,
                          height: 1.5),
                    ),
                  ],
                ),
              ),

              // Progreso compacto
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: GlassPanel(
                  backgroundColor: Colors.white.withValues(alpha: 0.56),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(Icons.insights_rounded,
                              color: SimcoreColors.accent),
                          Text('Progreso por Módulo',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ModuleFlowStepper(modules: workspace.modules),
                      const SizedBox(height: 18),
                      ...workspace.modules.map((m) => _MiniModuleRow(module: m)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // ── Alertas de incoherencia ──────────────────────────────────────────
        if (workspace.incoherences.isNotEmpty) ...[
          ResponsiveSectionWrap(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Incoherencias Detectadas'),
                    const SizedBox(height: 14),
                    ...workspace.incoherences.map(
                      (inc) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _IncoherenceRibbon(data: inc),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
        ],

        // ── Progreso detallado + decisiones pendientes ───────────────────────
        ResponsiveSectionWrap(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Resumen por Módulo'),
                  const SizedBox(height: 14),
                  ResponsiveWrap(
                    children: workspace.modules
                        .map((m) => _ModuleCard(module: m))
                        .toList(growable: false),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Progreso del Equipo',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(
                      '${workspace.completedModules} de ${workspace.modules.length} módulos completados',
                      style: const TextStyle(
                          color: SimcoreColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    ...workspace.modules.map((m) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: MetricBar(
                            label: m.name,
                            value: m.progress.toDouble(),
                            max: 100,
                            trailing: '${m.progress}%',
                            color: m.status == ModuleStatus.complete
                                ? SimcoreColors.success
                                : m.status == ModuleStatus.inProgress
                                    ? SimcoreColors.accent
                                    : SimcoreColors.textTertiary,
                          ),
                        )),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ── Trazabilidad reciente ────────────────────────────────────────────
        if (workspace.decisions.isNotEmpty) ...[
          const SizedBox(height: 28),
          const SectionLabel('Trazabilidad Reciente'),
          const SizedBox(height: 14),
          ...workspace.decisions
              .take(5)
              .map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DecisionTraceRow(data: d),
                  )),
        ],

        const SizedBox(height: 28),
      ],
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _MiniModuleRow extends StatelessWidget {
  const _MiniModuleRow({required this.module});

  final CompanyModuleProgress module;

  @override
  Widget build(BuildContext context) {
    final positive = module.status == ModuleStatus.complete ||
        module.status == ModuleStatus.inProgress;
    final color = _statusColor(module.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: positive
                  ? SimcoreColors.successSoft
                  : module.status == ModuleStatus.requiresRevision
                      ? SimcoreColors.warningSoft
                      : SimcoreColors.textTertiary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_statusIcon(module.status), size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(module.name,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          Text(
            '${module.progress}%',
            style: GoogleFonts.jetBrainsMono(
                color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module});

  final CompanyModuleProgress module;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(module.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              StatusBadge(status: module.status),
            ],
          ),
          if (module.status == ModuleStatus.requiresRevision &&
              module.revisionReason != null) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: SimcoreColors.warningSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 16, color: SimcoreColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      module.revisionReason!,
                      style: const TextStyle(
                          fontSize: 13,
                          color: SimcoreColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (module.status == ModuleStatus.outdated) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9C3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFEAB308).withValues(alpha: 0.4)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFEAB308)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Este módulo ha quedado desactualizado debido a cambios en decisiones previas. Por favor ingresa y actualiza los datos.',
                      style: TextStyle(fontSize: 13, color: Color(0xFFCA8A04)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          MetricBar(
            label: 'Progreso',
            value: module.progress.toDouble(),
            max: 100,
            trailing: '${module.progress}%',
          ),
          if (module.updatedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Actualizado: ${module.updatedAt}',
              style: const TextStyle(
                  fontSize: 12, color: SimcoreColors.textTertiary),
            ),
          ],
        ],
      ),
    );
  }
}

class _IncoherenceRibbon extends StatelessWidget {
  const _IncoherenceRibbon({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final level = (data['level'] ?? data['severity'] ?? 'MEDIUM').toString();
    final message =
        (data['message'] ?? data['description'] ?? 'Incoherencia detectada')
            .toString();
    final module = (data['module'] ?? data['moduleType'] ?? '').toString();

    final isHigh =
        level.toUpperCase() == 'HIGH' || level.toUpperCase() == 'ALTA';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHigh
            ? SimcoreColors.dangerSoft
            : SimcoreColors.warningSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHigh ? SimcoreColors.danger : SimcoreColors.warning,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isHigh
                ? Icons.error_outline_rounded
                : Icons.warning_amber_rounded,
            color: isHigh ? SimcoreColors.danger : SimcoreColors.warning,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                if (module.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Módulo: $module',
                    style: const TextStyle(
                        fontSize: 12,
                        color: SimcoreColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isHigh ? SimcoreColors.danger : SimcoreColors.warning,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              level.toUpperCase(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecisionTraceRow extends StatelessWidget {
  const _DecisionTraceRow({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final module =
        (data['moduleType'] ?? data['module'] ?? 'Módulo').toString();
    final status =
        (data['status'] ?? 'DRAFT').toString().toUpperCase();
    final updatedAt =
        (data['updatedAt'] ?? data['createdAt'] ?? '').toString();

    Color statusColor;
    if (status == 'SUBMITTED') {
      statusColor = SimcoreColors.success;
    } else if (status == 'SUPERSEDED') {
      statusColor = SimcoreColors.textTertiary;
    } else {
      statusColor = SimcoreColors.warning;
    }

    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: Colors.white.withValues(alpha: 0.6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              module,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            switch (status) {
              'SUBMITTED' => 'Enviada',
              'SUPERSEDED' => 'Reemplazada',
              'DRAFT' => 'Borrador',
              _ => status,
            },
            style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: statusColor,
                fontWeight: FontWeight.w700),
          ),
          if (updatedAt.isNotEmpty) ...[
            const SizedBox(width: 12),
            Text(
              updatedAt,
              style: const TextStyle(
                  fontSize: 11, color: SimcoreColors.textTertiary),
            ),
          ],
        ],
      ),
    );
  }
}

Color _statusColor(ModuleStatus status) {
  return switch (status) {
    ModuleStatus.complete => SimcoreColors.success,
    ModuleStatus.inProgress => SimcoreColors.accent,
    ModuleStatus.requiresRevision => SimcoreColors.warning,
    ModuleStatus.outdated => SimcoreColors.textTertiary,
    ModuleStatus.locked => SimcoreColors.danger,
    ModuleStatus.pending => SimcoreColors.textTertiary,
  };
}

IconData _statusIcon(ModuleStatus status) {
  return switch (status) {
    ModuleStatus.complete => Icons.check_circle_outline_rounded,
    ModuleStatus.inProgress => Icons.timelapse_rounded,
    ModuleStatus.requiresRevision => Icons.edit_note_rounded,
    ModuleStatus.outdated => Icons.history_rounded,
    ModuleStatus.locked => Icons.lock_outline_rounded,
    ModuleStatus.pending => Icons.radio_button_unchecked_rounded,
  };
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: SimcoreColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: SimcoreColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StageItem extends StatelessWidget {
  const _StageItem({
    required this.title,
    required this.progress,
    required this.color,
    required this.icon,
  });

  final String title;
  final int progress;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SimcoreColors.border.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: SimcoreColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 6,
                    backgroundColor: SimcoreColors.muted,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$progress%',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
