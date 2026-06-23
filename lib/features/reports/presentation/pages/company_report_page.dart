import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/auth/presentation/providers/auth_notifier.dart';
import 'package:simcore_frontend/features/reports/presentation/providers/report_providers.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/api_error_state.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/loading_state.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';
import 'package:simcore_frontend/features/comparison/presentation/providers/comparison_providers.dart';

class CompanyReportPage extends ConsumerWidget {
  const CompanyReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(narrativeReportProvider);
    final exportState = ref.watch(reportExportNotifierProvider);
    final user = ref.watch(authNotifierProvider).user;
    final ctx = ref.watch(simulationContextNotifierProvider).context;
    final selectedScenario = ref.watch(reportScenarioTypeProvider);

    ref.listen<AsyncValue<String?>>(reportExportNotifierProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        showSimcoreSuccessDialog(
          context: context,
          title: '¡Reporte Exportado!',
          message: next.value!,
        );
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageIntro(
          title: 'Reporte Final',
          subtitle:
              'Análisis narrativo e indicadores financieros consolidados.',
        ),
        const SizedBox(height: 16),
        _ScenarioSelector(selected: selectedScenario),
        const SizedBox(height: 20),
        if (exportState.isLoading)
          const LinearProgressIndicator()
        else if (exportState.hasError)
          _ErrorBanner(message: exportState.error.toString()),
        reportAsync.when(
          loading: () => const LoadingState(message: 'Generando reporte...'),
          error: (e, _) => ApiErrorState(
            title: 'No se pudo cargar el reporte',
            message: e.toString(),
            onRetry: () => ref.invalidate(narrativeReportProvider),
          ),
          data: (report) => _ReportBody(
            report: report,
            isTeacher: user != null && (user.isAdmin || user.isDocente),
            companyId: ctx?.companyId,
            courseId: ctx?.courseId,
            scenarioType: selectedScenario,
          ),
        ),
      ],
    );
  }
}

class _ScenarioSelector extends ConsumerWidget {
  const _ScenarioSelector({required this.selected});

  final String selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const options = ['PROBABLE', 'OPTIMISTIC', 'PESSIMISTIC'];
    const labels = {
      'PROBABLE': 'Probable',
      'OPTIMISTIC': 'Optimista',
      'PESSIMISTIC': 'Pesimista',
    };
    return Wrap(
      spacing: 8,
      children: options.map((opt) {
        final active = opt == selected;
        return ChoiceChip(
          label: Text(labels[opt] ?? opt),
          selected: active,
          selectedColor: SimcoreColors.accent,
          labelStyle: TextStyle(
            color: active ? Colors.white : SimcoreColors.textSecondary,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
          onSelected: (_) =>
              ref.read(reportScenarioTypeProvider.notifier).state = opt,
        );
      }).toList(),
    );
  }
}

class _ReportBody extends ConsumerWidget {
  const _ReportBody({
    required this.report,
    required this.isTeacher,
    required this.companyId,
    required this.courseId,
    required this.scenarioType,
  });

  final Map<String, dynamic> report;
  final bool isTeacher;
  final int? companyId;
  final int? courseId;
  final String scenarioType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparisonAsync = ref.watch(courseComparisonProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ExportPanel(
          isTeacher: isTeacher,
          companyId: companyId,
          courseId: courseId,
          scenarioType: scenarioType,
          report: report,
        ),
        const SizedBox(height: 24),

        // ── Indicadores ────────────────────────────────────────────────────
        const SectionLabel('Indicadores Financieros'),
        const SizedBox(height: 12),
        _IndicatorsPanel(report: report),
        const SizedBox(height: 24),

        // ── Reporte Narrativo ──────────────────────────────────────────────
        const SectionLabel('Reporte Narrativo'),
        const SizedBox(height: 12),
        _NarrativePanel(report: report),
        const SizedBox(height: 24),

        // ── Incoherencias ──────────────────────────────────────────────────
        if ((report['incoherences'] as List?)?.isNotEmpty ?? false) ...[
          const SectionLabel('Incoherencias del Reporte'),
          const SizedBox(height: 12),
          _IncoherencesPanel(items: report['incoherences'] as List),
          const SizedBox(height: 24),
        ],

        // ── Decisiones clave ───────────────────────────────────────────────
        if ((report['keyDecisions'] as List?)?.isNotEmpty ?? false) ...[
          const SectionLabel('Decisiones Clave'),
          const SizedBox(height: 12),
          _KeyDecisionsPanel(items: report['keyDecisions'] as List),
          const SizedBox(height: 24),
        ],

        // ── Cierre de Simulación (Debriefing) ────────────────────────────────
        if (isTeacher) ...[
          const SectionLabel('Cierre de Simulación (Debriefing)'),
          const SizedBox(height: 12),
          comparisonAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Text(
              'Error al cargar cierre de simulación: $err',
              style: const TextStyle(color: SimcoreColors.danger),
            ),
            data: (data) {
              final companies = (data['companies'] as List? ?? [])
                  .map((e) => Map<String, dynamic>.from(e as Map))
                  .toList();
              return _DebriefingPanel(companies: companies);
            },
          ),
          const SizedBox(height: 24),
        ],

        const SizedBox(height: 28),
      ],
    );
  }
}

class _ExportPanel extends ConsumerWidget {
  const _ExportPanel({
    required this.isTeacher,
    required this.companyId,
    required this.courseId,
    required this.scenarioType,
    required this.report,
  });

  final bool isTeacher;
  final int? companyId;
  final int? courseId;
  final String scenarioType;
  final Map<String, dynamic> report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = _reportSummary(report);

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveHeaderAction(
            title: 'Exportes',
            subtitle: 'Escenario $scenarioType',
            action: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: companyId != null
                      ? () => ref
                          .read(reportExportNotifierProvider.notifier)
                          .downloadPdf(companyId)
                      : null,
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('PDF'),
                ),
                if (isTeacher)
                  OutlinedButton.icon(
                    onPressed: courseId != null
                        ? () => ref
                            .read(reportExportNotifierProvider.notifier)
                            .downloadCsv(courseId)
                        : null,
                    icon: const Icon(Icons.table_chart_rounded),
                    label: const Text('CSV'),
                  ),
                OutlinedButton.icon(
                  onPressed: summary.isEmpty
                      ? null
                      : () async {
                          await Clipboard.setData(ClipboardData(text: summary));
                          if (!context.mounted) return;
                          showSimcoreSuccessDialog(
                            context: context,
                            title: '¡Resumen Copiado!',
                            message: 'El resumen ejecutivo se ha copiado al portapapeles exitosamente.',
                          );
                        },
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copiar'),
                ),
              ],
            ),
          ),
          if (summary.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SimcoreColors.muted,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: SimcoreColors.border),
              ),
              child: Text(
                summary,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: SimcoreColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _reportSummary(Map<String, dynamic> report) {
  final parts = [
    report['executiveNarrative'],
    report['viabilitySummary'],
    report['conclusions'],
  ]
      .where((value) => value != null && value.toString().trim().isNotEmpty)
      .map((value) => value.toString().trim())
      .toList(growable: false);
  return parts.join('\n\n');
}

class _IndicatorsPanel extends StatelessWidget {
  const _IndicatorsPanel({required this.report});

  final Map<String, dynamic> report;

  String _pct(dynamic v) =>
      v != null ? '${((v as num) * 100).toStringAsFixed(1)}%' : '-';

  @override
  Widget build(BuildContext context) {
    final van = report['van'] as num?;
    final tir = report['tir'] as num?;
    final pri = report['priMonths'] as num?;
    final grossM = report['grossMarginPct'];
    final netM = report['netMarginPct'];
    final roi = report['roiPct'];

    return GlassPanel(
      child: Wrap(
        spacing: 24,
        runSpacing: 16,
        children: [
          _KpiTile(
              label: 'VAN', value: van != null ? van.toStringAsFixed(0) : '-'),
          _KpiTile(label: 'TIR', value: tir != null ? _pct(tir) : '-'),
          _KpiTile(label: 'PRI (meses)', value: pri?.toString() ?? '-'),
          _KpiTile(label: 'Margen Bruto', value: _pct(grossM)),
          _KpiTile(label: 'Margen Neto', value: _pct(netM)),
          _KpiTile(label: 'ROI', value: _pct(roi)),
        ],
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: SimcoreColors.textTertiary)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: SimcoreColors.accent)),
      ],
    );
  }
}

class _NarrativePanel extends StatelessWidget {
  const _NarrativePanel({required this.report});

  final Map<String, dynamic> report;

  @override
  Widget build(BuildContext context) {
    final sections = {
      'Resumen de Mercado': report['marketSummary'],
      'Resumen de Inversión': report['investmentSummary'],
      'Resumen Organizacional': report['organizationSummary'],
      'Resumen Contable': report['accountingSummary'],
      'Viabilidad': report['viabilitySummary'],
      'Narrativa Ejecutiva': report['executiveNarrative'],
      'Conclusiones': report['conclusions'],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.entries
          .where((e) => e.value != null && e.value.toString().isNotEmpty)
          .map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.key,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(e.value.toString(),
                          style: const TextStyle(
                              fontSize: 14,
                              color: SimcoreColors.textSecondary,
                              height: 1.5)),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _IncoherencesPanel extends StatelessWidget {
  const _IncoherencesPanel({required this.items});

  final List items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        final m = Map<String, dynamic>.from(item as Map);
        final msg = (m['message'] ?? m['description'] ?? '').toString();
        final level = (m['level'] ?? 'MEDIUM').toString().toUpperCase();
        final isHigh = level == 'HIGH';
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                isHigh ? SimcoreColors.dangerSoft : SimcoreColors.warningSoft,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isHigh ? SimcoreColors.danger : SimcoreColors.warning,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isHigh
                    ? Icons.error_outline_rounded
                    : Icons.warning_amber_rounded,
                color: isHigh ? SimcoreColors.danger : SimcoreColors.warning,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(msg)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _KeyDecisionsPanel extends StatelessWidget {
  const _KeyDecisionsPanel({required this.items});

  final List items;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          final m = Map<String, dynamic>.from(item as Map);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.arrow_right_rounded,
                    color: SimcoreColors.accent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    (m['description'] ?? m['module'] ?? m.toString())
                        .toString(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}



class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SimcoreColors.dangerSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SimcoreColors.danger.withValues(alpha: 0.4)),
      ),
      child: Text(message, style: const TextStyle(color: SimcoreColors.danger)),
    );
  }
}

class _DebriefingPanel extends StatelessWidget {
  const _DebriefingPanel({required this.companies});

  final List<Map<String, dynamic>> companies;

  @override
  Widget build(BuildContext context) {
    if (companies.isEmpty) {
      return GlassPanel(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: SimcoreColors.muted,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.forum_outlined,
                    size: 40,
                    color: SimcoreColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cierre de Simulación no Disponible',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: SimcoreColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aún no hay suficientes datos en el curso para generar el cierre de simulación y las métricas de cohorte.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: SimcoreColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final vList = companies.map((c) => (c['van'] as num?)?.toDouble() ?? 0.0).toList();
    final avgVan = vList.isEmpty ? 0.0 : vList.reduce((a, b) => a + b) / vList.length;
    
    final sortedByVan = List<Map<String, dynamic>>.from(companies)
      ..sort((a, b) {
        final vanA = (a['van'] as num?)?.toDouble() ?? 0.0;
        final vanB = (b['van'] as num?)?.toDouble() ?? 0.0;
        return vanB.compareTo(vanA);
      });

    final bestPerformers = sortedByVan.where((c) => c['viable'] == true).take(2).toList();
    final top2 = bestPerformers.length >= 2 ? bestPerformers : sortedByVan.take(2).toList();

    final sortedByErrors = List<Map<String, dynamic>>.from(companies)
      ..sort((a, b) {
        final incA = (a['incoherencesHigh'] as num?)?.toInt() ?? 0;
        final incB = (b['incoherencesHigh'] as num?)?.toInt() ?? 0;
        if (incB != incA) return incB.compareTo(incA);
        final vanA = (a['van'] as num?)?.toDouble() ?? 0.0;
        final vanB = (b['van'] as num?)?.toDouble() ?? 0.0;
        return vanA.compareTo(vanB);
      });

    final commonErrors = sortedByErrors.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricSummaryCard(
                title: 'VAN Promedio Cohorte',
                value: '\$${avgVan.toStringAsFixed(0)}',
                icon: Icons.analytics_rounded,
                color: const Color(0xFF0284C7),
                bgGradient: const LinearGradient(
                  colors: [Color(0xFFE0F2FE), Color(0xFFF0F9FF)],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MetricSummaryCard(
                title: 'Mejor VAN Registrado',
                value: sortedByVan.isNotEmpty
                    ? '\$${((sortedByVan[0]['van'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(0)}'
                    : '-',
                icon: Icons.emoji_events_rounded,
                color: const Color(0xFFD97706),
                bgGradient: const LinearGradient(
                  colors: [Color(0xFFFEF3C7), Color(0xFFFFFBEB)],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final cardWidgets = [
              _buildDebriefGroupCard(
                title: 'Mejores Prácticas (Top Rendimiento)',
                icon: Icons.star_rounded,
                accentColor: SimcoreColors.success,
                items: top2,
                isErrorType: false,
              ),
              _buildDebriefGroupCard(
                title: 'Patrones Comunes de Error o Riesgo',
                icon: Icons.warning_rounded,
                accentColor: SimcoreColors.danger,
                items: commonErrors,
                isErrorType: true,
              ),
            ];

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: cardWidgets[0]),
                  const SizedBox(width: 16),
                  Expanded(child: cardWidgets[1]),
                ],
              );
            } else {
              return Column(
                children: [
                  cardWidgets[0],
                  const SizedBox(height: 16),
                  cardWidgets[1],
                ],
              );
            }
          },
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SimcoreColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.forum_rounded, color: SimcoreColors.accent),
                  SizedBox(width: 10),
                  Text(
                    'Preguntas Guiadas de Cierre (Debriefing)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: SimcoreColors.textPrimary),
                  ),
                ],
              ),
              const Divider(height: 20),
              _buildDiscussionQuestion(1, '¿Cómo impactó la estructura de inversión inicial en la viabilidad a largo plazo de los proyectos con peor rendimiento?'),
              _buildDiscussionQuestion(2, '¿Por qué algunos grupos obtuvieron un VAN negativo a pesar de reportar altos ingresos? (Analizar márgenes operativos vs. costos fijos).'),
              _buildDiscussionQuestion(3, '¿Qué inconsistencias de mercado fueron determinantes en la degradación de la coherencia global?'),
              _buildDiscussionQuestion(4, 'Si pudieran reiniciar el ciclo de decisiones, ¿qué variables de financiamiento modificarían para elevar el ROI?'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiscussionQuestion(int number, String question) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: SimcoreColors.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: SimcoreColors.accent),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              question,
              style: const TextStyle(fontSize: 13, color: SimcoreColors.textPrimary, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebriefGroupCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required List<Map<String, dynamic>> items,
    required bool isErrorType,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SimcoreColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const Divider(height: 20),
          if (items.isEmpty)
            const Text('Sin datos disponibles.', style: TextStyle(fontSize: 12, color: SimcoreColors.textSecondary))
          else
            ...items.map((item) {
              final van = item['van'] as num?;
              final margin = item['netMarginPct'] as num?;
              final incoherences = item['incoherencesHigh'] as num? ?? 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (item['companyName'] ?? '-').toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            (item['groupName'] ?? '-').toString(),
                            style: const TextStyle(fontSize: 11, color: SimcoreColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          van != null ? 'VAN: \$${van.toStringAsFixed(0)}' : 'VAN: -',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isErrorType && (van ?? 0) < 0 ? SimcoreColors.danger : SimcoreColors.textPrimary,
                          ),
                        ),
                        Text(
                          isErrorType
                              ? '$incoherences incoherencias altas'
                              : 'Margen: ${margin != null ? (margin * 100).toStringAsFixed(1) : "-"}%',
                          style: const TextStyle(fontSize: 10, color: SimcoreColors.textTertiary),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _MetricSummaryCard extends StatelessWidget {
  const _MetricSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgGradient,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Gradient bgGradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
