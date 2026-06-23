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

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SimcoreColors.successSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SimcoreColors.success.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: SimcoreColors.success, size: 18),
          const SizedBox(width: 8),
          Text(message, style: const TextStyle(color: SimcoreColors.success)),
        ],
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
