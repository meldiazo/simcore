import 'package:core_sim_ia/app/router.dart';
import 'package:core_sim_ia/app/theme.dart';
import 'package:core_sim_ia/features/stratova/data/stratova_mock_data.dart';
import 'package:core_sim_ia/features/stratova/presentation/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkspacePage extends StatelessWidget {
  const WorkspacePage({super.key});

  @override
  Widget build(BuildContext context) {
    final completedModules = decisionModules
        .where((module) => module.status == DecisionStatus.submitted)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageIntro(
          title: 'Workspace Ejecutivo',
          subtitle: 'Panel de control y metricas clave para Equipo Alpha',
        ),
        const SizedBox(height: 28),
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
                            color: StratovaColors.accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            currentCycle.name.toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12),
                          ),
                        ),
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle,
                                size: 10, color: StratovaColors.success),
                            SizedBox(width: 8),
                            Text('Recibiendo decisiones',
                                style: TextStyle(fontWeight: FontWeight.w600)),
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
                              ?.copyWith(fontSize: headlineSize, height: 1.08),
                          children: [
                            const TextSpan(text: 'Cierre en '),
                            TextSpan(
                              text: currentCycle.timeRemaining,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: headlineSize,
                                fontWeight: FontWeight.w700,
                                color: StratovaColors.accent,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 14),
                    Text(
                      'El motor de simulacion procesara las estrategias al finalizar. Tu equipo ha completado $completedModules de ${decisionModules.length} modulos obligatorios.',
                      style: const TextStyle(
                          fontSize: 15,
                          color: StratovaColors.textSecondary,
                          height: 1.5),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: GlassPanel(
                  backgroundColor: Colors.white.withValues(alpha: 0.56),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(Icons.insights_rounded,
                              color: StratovaColors.accent),
                          Text('Resumen Ciclo Anterior',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                      SizedBox(height: 18),
                      _MiniMetric(
                          label: 'Rentabilidad',
                          value: '+2.3%',
                          positive: true),
                      _MiniMetric(
                          label: 'Cuota Mrc.', value: '+1.2%', positive: true),
                      _MiniMetric(
                          label: 'Liquidez', value: '-0.3x', positive: false),
                      _MiniMetric(
                          label: 'Ranking', value: '#2 / 5', positive: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ResponsiveWrap(
            children: kpiData
                .take(4)
                .map((metric) => KpiCard(metric: metric))
                .toList(growable: false)),
        const SizedBox(height: 28),
        ResponsiveSectionWrap(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Alertas Criticas'),
                  const SizedBox(height: 14),
                  ...alerts.map((alert) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AlertRibbon(alert: alert),
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
                    const Text('Progreso del Equipo',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(
                      '$completedModules de ${decisionModules.length} modulos completados',
                      style:
                          const TextStyle(color: StratovaColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    ...decisionModules.map((module) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: MetricBar(
                            label: module.name,
                            value: module.progress.toDouble(),
                            max: 100,
                            trailing: '${module.progress}%',
                            color: module.status == DecisionStatus.submitted
                                ? StratovaColors.success
                                : module.status == DecisionStatus.draft
                                    ? StratovaColors.accent
                                    : StratovaColors.textTertiary,
                          ),
                        )),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(AppRouter.decisions),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Centro de Decisiones'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const SectionLabel('Resumen por Modulo'),
        const SizedBox(height: 14),
        ResponsiveWrap(
          children: decisionModules.map((module) {
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
                  const SizedBox(height: 16),
                  ...module.summary.map((line) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(line,
                            style: const TextStyle(
                                color: StratovaColors.textSecondary)),
                      )),
                  const SizedBox(height: 12),
                  MetricBar(
                    label: 'Progreso',
                    value: module.progress.toDouble(),
                    max: 100,
                    trailing: '${module.progress}%',
                  ),
                ],
              ),
            );
          }).toList(growable: false),
        ),
      ],
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    required this.positive,
  });

  final String label;
  final String value;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: positive
                  ? StratovaColors.successSoft
                  : StratovaColors.warningSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              positive
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              size: 18,
              color: positive ? StratovaColors.success : StratovaColors.warning,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              color: positive ? StratovaColors.success : StratovaColors.warning,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
