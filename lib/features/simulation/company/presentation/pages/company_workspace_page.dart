import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simcore_frontend/app/router/app_router.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/api_error_state.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/loading_state.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/module_flow_stepper.dart';
import 'package:simcore_frontend/features/simulation/company/domain/entities/module_progress.dart';
import 'package:simcore_frontend/features/simulation/company/presentation/providers/company_providers.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

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

class _WorkspaceBody extends StatelessWidget {
  const _WorkspaceBody({required this.workspace});

  final CompanyWorkspaceData workspace;

  @override
  Widget build(BuildContext context) {
    final scenario = workspace.activeScenario;
    final scenarioName = scenario?['name']?.toString() ??
        scenario?['type']?.toString() ??
        'Escenario activo';
    final cycleLabel = scenario?['cycle']?.toString() ??
        scenario?['period']?.toString() ??
        'Ciclo actual';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageIntro(
          title: 'Workspace Ejecutivo',
          subtitle: 'Panel de control — ${workspace.company.name}',
        ),
        const SizedBox(height: 28),

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
