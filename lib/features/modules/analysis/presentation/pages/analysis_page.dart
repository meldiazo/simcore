import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/modules/analysis/data/models/consolidated_analysis_model.dart';
import 'package:simcore_frontend/features/modules/analysis/presentation/providers/analysis_providers.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/models/decision_model.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/repositories/decision_providers.dart';

class AnalysisPage extends ConsumerWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(consolidatedAnalysisProvider);
    final decisionsAsync = ref.watch(companyDecisionsProvider);
    final notifierState = ref.watch(analysisNotifierProvider);
    final isLoading = notifierState is AsyncLoading;

    return analysisAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text(
        'Error: $e',
        style: const TextStyle(color: SimcoreColors.danger),
      ),
      data: (analysis) => _AnalysisContent(
        analysis: analysis,
        decisionsAsync: decisionsAsync,
        isLoading: isLoading,
      ),
    );
  }
}

class _AnalysisContent extends ConsumerWidget {
  const _AnalysisContent({
    required this.analysis,
    required this.decisionsAsync,
    required this.isLoading,
  });

  final ConsolidatedAnalysisModel? analysis;
  final AsyncValue<List<DecisionModel>> decisionsAsync;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indicators = analysis?.financialIndicators ?? const {};
    final incoherences = analysis?.incoherences ?? const [];
    final report = analysis?.narrativeReport ?? const {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageIntro(
          title: 'AnÃ¡lisis General',
          subtitle:
              'Indicadores financieros, incoherencias y narrativa del plan.',
        ),
        const SizedBox(height: 24),
        GlassPanel(child: _IndicatorsView(indicators: indicators)),
        const SizedBox(height: 20),
        GlassPanel(child: _IncoherencesView(incoherences: incoherences)),
        const SizedBox(height: 20),
        GlassPanel(child: _NarrativeView(report: report)),
        const SizedBox(height: 20),
        GlassPanel(child: _DecisionsView(decisionsAsync: decisionsAsync)),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: !isLoading
              ? () =>
                  ref.read(analysisNotifierProvider.notifier).completeModule()
              : null,
          style: FilledButton.styleFrom(backgroundColor: SimcoreColors.success),
          child: const Text('Completar mÃ³dulo AnÃ¡lisis'),
        ),
      ],
    );
  }
}

class _IndicatorsView extends StatelessWidget {
  const _IndicatorsView({required this.indicators});

  final Map<String, dynamic> indicators;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const IconTitle(
          icon: Icons.insert_chart_outlined_rounded,
          title: 'Indicadores Financieros',
        ),
        const SizedBox(height: 16),
        if (indicators.isEmpty)
          const Text(
            'Sin indicadores. Completa los mÃ³dulos anteriores.',
            style: TextStyle(color: SimcoreColors.textSecondary),
          )
        else
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: _indicatorLabels.entries.map((entry) {
              final val = indicators[entry.key];
              if (val == null) return const SizedBox.shrink();
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: SimcoreColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SimcoreColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 11,
                        color: SimcoreColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      val.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _IncoherencesView extends StatelessWidget {
  const _IncoherencesView({required this.incoherences});

  final List<Map<String, dynamic>> incoherences;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const IconTitle(
          icon: Icons.warning_amber_rounded,
          title: 'Incoherencias detectadas',
        ),
        const SizedBox(height: 16),
        if (incoherences.isEmpty)
          const Text(
            'Sin incoherencias detectadas.',
            style: TextStyle(color: SimcoreColors.success),
          )
        else
          Column(
            children:
                incoherences.map((i) => _IncoherenceTile(data: i)).toList(),
          ),
      ],
    );
  }
}

class _NarrativeView extends StatelessWidget {
  const _NarrativeView({required this.report});

  final Map<String, dynamic> report;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const IconTitle(
          icon: Icons.description_outlined,
          title: 'Narrativa del plan',
        ),
        const SizedBox(height: 16),
        if (report.isEmpty)
          const Text(
            'Sin reporte narrativo disponible.',
            style: TextStyle(color: SimcoreColors.textSecondary),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (report['marketSummary'] != null)
                _ReportSectionWidget(
                  title: 'Mercado',
                  content: report['marketSummary'].toString(),
                ),
              if (report['investmentSummary'] != null)
                _ReportSectionWidget(
                  title: 'InversiÃ³n',
                  content: report['investmentSummary'].toString(),
                ),
              if (report['organizationSummary'] != null)
                _ReportSectionWidget(
                  title: 'OrganizaciÃ³n',
                  content: report['organizationSummary'].toString(),
                ),
            ],
          ),
      ],
    );
  }
}

class _DecisionsView extends StatelessWidget {
  const _DecisionsView({required this.decisionsAsync});

  final AsyncValue<List<DecisionModel>> decisionsAsync;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const IconTitle(
          icon: Icons.check_circle_outline_rounded,
          title: 'Decisiones clave',
        ),
        const SizedBox(height: 16),
        decisionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(
            'Error: $e',
            style: const TextStyle(color: SimcoreColors.danger),
          ),
          data: (decisions) {
            if (decisions.isEmpty) {
              return const Text(
                'Sin decisiones registradas.',
                style: TextStyle(color: SimcoreColors.textSecondary),
              );
            }

            return Column(
              children: decisions.map((decision) {
                final dynamic d = decision;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: SimcoreColors.accentSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          d.module.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: SimcoreColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          d.justification.toString(),
                          style: const TextStyle(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
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
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
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
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: SimcoreColors.accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              color: SimcoreColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

const _indicatorLabels = {
  'van': 'VAN',
  'tir': 'TIR (%)',
  'pri': 'PRI (aÃ±os)',
  'grossMargin': 'Margen Bruto (%)',
  'netMargin': 'Margen Neto (%)',
  'roi': 'ROI (%)',
};
