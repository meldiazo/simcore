import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/ai/presentation/providers/ai_providers.dart';
import 'package:simcore_frontend/features/ai/presentation/widgets/ai_suggestion_card.dart';
import 'package:simcore_frontend/features/modules/analysis/presentation/providers/analysis_providers.dart';
import 'package:simcore_frontend/features/simulation/decisions/presentation/providers/decision_providers.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalysisPage extends ConsumerWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indicatorsAsync = ref.watch(financialIndicatorsProvider);
    final incoherencesAsync = ref.watch(analysisIncoherencesProvider);
    final reportAsync = ref.watch(narrativeReportProvider);
    final decisionsAsync = ref.watch(companyDecisionsProvider);
    final ratioAiAsync = ref.watch(ratioExplanationAiProvider);
    final narrativeAiAsync = ref.watch(narrativeAiProvider);
    final notifierState = ref.watch(analysisNotifierProvider);
    final isLoading = notifierState is AsyncLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageIntro(
          title: 'Análisis General',
          subtitle:
              'Indicadores financieros, incoherencias y narrativa del plan.',
        ),
        const SizedBox(height: 24),

        // Financial Indicators
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconTitle(
                icon: Icons.insert_chart_outlined_rounded,
                title: 'Indicadores Financieros',
              ),
              const SizedBox(height: 16),
              indicatorsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e',
                    style: const TextStyle(color: SimcoreColors.danger)),
                data: (indicators) {
                  if (indicators == null || indicators.isEmpty) {
                    return const Text(
                      'Sin indicadores. Completa los módulos anteriores.',
                      style: TextStyle(color: SimcoreColors.textSecondary),
                    );
                  }
                  final keys = [
                    'van',
                    'tir',
                    'pri',
                    'grossMargin',
                    'netMargin',
                    'roi'
                  ];
                  final labels = {
                    'van': 'VAN',
                    'tir': 'TIR (%)',
                    'pri': 'PRI (años)',
                    'grossMargin': 'Margen Bruto (%)',
                    'netMargin': 'Margen Neto (%)',
                    'roi': 'ROI (%)',
                  };
                  return Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: keys.map((k) {
                      final val = indicators[k];
                      if (val == null) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: SimcoreColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: SimcoreColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(labels[k] ?? k,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: SimcoreColors.textTertiary)),
                            const SizedBox(height: 4),
                            Text(
                              val.toString(),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconTitle(
                icon: Icons.auto_awesome_rounded,
                title: 'Asistente IA',
              ),
              const SizedBox(height: 16),
              AiSuggestionCard(
                title: 'Explicación de ratios',
                icon: Icons.query_stats_rounded,
                suggestionAsync: ratioAiAsync,
              ),
              const SizedBox(height: 12),
              AiSuggestionCard(
                title: 'Narrativa ejecutiva',
                icon: Icons.psychology_alt_rounded,
                suggestionAsync: narrativeAiAsync,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Incoherences
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconTitle(
                icon: Icons.warning_amber_rounded,
                title: 'Incoherencias detectadas',
              ),
              const SizedBox(height: 16),
              incoherencesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e',
                    style: const TextStyle(color: SimcoreColors.danger)),
                data: (incoherences) {
                  if (incoherences.isEmpty) {
                    return const Text(
                      'Sin incoherencias detectadas.',
                      style: TextStyle(color: SimcoreColors.success),
                    );
                  }
                  return Column(
                    children: incoherences
                        .map((i) => _IncoherenceTile(data: i))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Narrative report
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconTitle(
                icon: Icons.description_outlined,
                title: 'Narrativa del plan',
              ),
              const SizedBox(height: 16),
              reportAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e',
                    style: const TextStyle(color: SimcoreColors.danger)),
                data: (report) {
                  if (report == null) {
                    return const Text(
                      'Sin reporte narrativo disponible.',
                      style: TextStyle(color: SimcoreColors.textSecondary),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (report['marketSummary'] != null)
                        _ReportSectionWidget(
                            title: 'Mercado',
                            content: report['marketSummary'].toString()),
                      if (report['investmentSummary'] != null)
                        _ReportSectionWidget(
                            title: 'Inversión',
                            content: report['investmentSummary'].toString()),
                      if (report['organizationSummary'] != null)
                        _ReportSectionWidget(
                            title: 'Organización',
                            content: report['organizationSummary'].toString()),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Key decisions
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconTitle(
                icon: Icons.check_circle_outline_rounded,
                title: 'Decisiones clave',
              ),
              const SizedBox(height: 16),
              decisionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e',
                    style: const TextStyle(color: SimcoreColors.danger)),
                data: (decisions) {
                  if (decisions.isEmpty) {
                    return const Text(
                      'Sin decisiones registradas.',
                      style: TextStyle(color: SimcoreColors.textSecondary),
                    );
                  }
                  return Column(
                    children: decisions
                        .map((d) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: SimcoreColors.accentSoft,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(d.module,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: SimcoreColors.accent,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: Text(d.justification,
                                          style: const TextStyle(height: 1.4))),
                                ],
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: !isLoading
              ? () =>
                  ref.read(analysisNotifierProvider.notifier).completeModule()
              : null,
          style: FilledButton.styleFrom(backgroundColor: SimcoreColors.success),
          child: const Text('Completar módulo Análisis'),
        ),
      ],
    );
  }
}

class _IncoherenceTile extends StatelessWidget {
  const _IncoherenceTile({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final level = data['level']?.toString() ?? 'LOW';
    final (color, bg) = switch (level.toUpperCase()) {
      'HIGH' => (SimcoreColors.danger, SimcoreColors.dangerSoft),
      'MEDIUM' => (SimcoreColors.warning, SimcoreColors.warningSoft),
      _ => (const Color(0xFFFBBF24), const Color(0xFFFEF9C3)),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                level,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w700, fontSize: 11),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                data['message']?.toString() ??
                    data['description']?.toString() ??
                    '',
                style: const TextStyle(height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportSectionWidget extends StatelessWidget {
  const _ReportSectionWidget({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: SimcoreColors.accent)),
          const SizedBox(height: 6),
          Text(content,
              style: const TextStyle(
                  color: SimcoreColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}
