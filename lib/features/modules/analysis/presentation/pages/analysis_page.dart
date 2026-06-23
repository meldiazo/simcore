import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/core/network/api_exception.dart';
import 'package:simcore_frontend/features/ai/presentation/providers/ai_providers.dart';
import 'package:simcore_frontend/features/ai/presentation/widgets/ai_suggestion_card.dart';
import 'package:simcore_frontend/features/modules/analysis/presentation/providers/analysis_providers.dart';
import 'package:simcore_frontend/features/simulation/decisions/presentation/providers/decision_providers.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_providers.dart' as global_providers;
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';
import 'package:simcore_frontend/features/simulation/module_progress/presentation/providers/module_progress_providers.dart' as module_actions;
import 'package:simcore_frontend/features/simulation/company/presentation/providers/company_providers.dart' as company_providers;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalysisPage extends ConsumerStatefulWidget {
  const AnalysisPage({super.key});

  @override
  ConsumerState<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends ConsumerState<AnalysisPage> {
  bool _hasStarted = false;

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
              SimModule.analysis.toApi(),
            );
      });
    }

    final indicatorsAsync = ref.watch(financialIndicatorsProvider);
    final incoherencesAsync = ref.watch(analysisIncoherencesProvider);
    final reportAsync = ref.watch(narrativeReportProvider);
    final decisionsAsync = ref.watch(companyDecisionsProvider);
    final ratioAiAsync = ref.watch(ratioExplanationAiProvider);
    final narrativeAiAsync = ref.watch(narrativeAiProvider);
    final notifierState = ref.watch(analysisNotifierProvider);
    final isLoading = notifierState is AsyncLoading;

    final companyAsync = ref.watch(company_providers.companyDetailProvider);
    final company = companyAsync.value;
    final isProductLaunch = company?.simulationType == SimulationType.productLaunch;

    final modulesAsync = ref.watch(global_providers.moduleProgressProvider);
    final isCompleted = modulesAsync.maybeWhen(
      data: (modules) => modules.any(
        (m) => m.module == SimModule.analysis && m.status == ModuleStatus.complete,
      ),
      orElse: () => false,
    );

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

        if (isProductLaunch) ...[
          const _IncrementalAnalysisPanel(),
          const SizedBox(height: 20),
          const _AiSimulationPanel(),
          const SizedBox(height: 20),
        ],

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
        ModuleFinalizeCard(
          title: 'Finalizar Módulo de Análisis General',
          subtitle: 'Al completar, se guardará la narrativa y los indicadores del plan para este ciclo de simulación.',
          onFinalize: !isLoading && !isCompleted
              ? () async {
                  final companyId = ref.read(currentCompanyIdProvider).toString();
                  try {
                    // 1. Force start the module explicitly
                    await ref.read(module_actions.moduleProgressProvider.notifier).start(
                          companyId,
                          SimModule.analysis.toApi(),
                        );

                    // Wait 300ms for server processing
                    await Future.delayed(const Duration(milliseconds: 300));

                    // 2. Complete module via analysis notifier
                    await ref.read(analysisNotifierProvider.notifier).completeModule();
                    
                    final finalState = ref.read(analysisNotifierProvider);
                    if (finalState.hasError) {
                      final error = finalState.error;
                      final cleanMessage = error is ApiException ? error.message : error.toString();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al completar el módulo de análisis: $cleanMessage'),
                            backgroundColor: SimcoreColors.danger,
                          ),
                        );
                      }
                    } else {
                      // 3. Mark module progress as complete globally
                      await ref.read(module_actions.moduleProgressProvider.notifier).complete(
                            companyId,
                            SimModule.analysis.toApi(),
                          );

                      if (context.mounted) {
                        // Invalidate providers to refresh UI and sidebar
                        ref.invalidate(company_providers.companyModuleProgressProvider);
                        ref.invalidate(company_providers.companyWorkspaceProvider);
                        ref.invalidate(global_providers.moduleProgressProvider);

                        showSimcoreSuccessDialog(
                          context: context,
                          title: '¡Módulo Completado!',
                          message: 'El módulo de Análisis General se ha finalizado correctamente para este ciclo.',
                        );
                      }
                    }
                  } catch (e) {
                    final cleanMessage = e is ApiException ? e.message : e.toString();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al completar el módulo de análisis: $cleanMessage'),
                          backgroundColor: SimcoreColors.danger,
                        ),
                      );
                    }
                  }
                }
              : null,
          buttonLabel: 'Completar Módulo',
          isCompleted: isCompleted,
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

class _IncrementalAnalysisPanel extends ConsumerWidget {
  const _IncrementalAnalysisPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incrementalAsync = ref.watch(incrementalAnalysisProvider);

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: IconTitle(
                  icon: Icons.add_chart_rounded,
                  title: 'Análisis Incremental',
                ),
              ),
              incrementalAsync.maybeWhen(
                data: (data) => data != null
                    ? ElevatedButton.icon(
                        onPressed: () => _showEditDialog(context, ref, data),
                        icon: const Icon(Icons.edit_note_rounded),
                        label: const Text('Editar Flujos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SimcoreColors.accentSoft,
                          foregroundColor: SimcoreColors.accent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          incrementalAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(
              'Error al cargar análisis incremental: $e',
              style: const TextStyle(color: SimcoreColors.danger),
            ),
            data: (data) {
              if (data == null) {
                return const Text(
                  'No hay datos de análisis incremental disponibles.',
                  style: TextStyle(color: SimcoreColors.textSecondary),
                );
              }

              final totalRev = data['totalIncrementalRevenue'] ?? 0.0;
              final totalOpex = data['totalIncrementalOpex'] ?? 0.0;
              final launchInv = data['totalLaunchInvestment'] ?? 0.0;
              final cannibalization = data['totalCannibalization'] ?? 0.0;
              final vanInc = data['vanIncremental'] ?? 0.0;
              final payback = data['paybackMonth'] ?? 0;
              final marginImpact = data['marginImpactPp'] ?? 0.0;
              final periods = List<Map<String, dynamic>>.from(
                (data['periods'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildMiniKpiCard(
                        title: 'VAN Incremental',
                        value: '\$${_formatMoney(vanInc)}',
                        highlight: true,
                      ),
                      _buildMiniKpiCard(
                        title: 'Impacto en Margen',
                        value: '${marginImpact >= 0 ? '+' : ''}${marginImpact.toStringAsFixed(2)} pp',
                        color: marginImpact >= 0 ? SimcoreColors.success : SimcoreColors.danger,
                      ),
                      _buildMiniKpiCard(
                        title: 'Periodo Recuperación',
                        value: payback > 0 ? '$payback meses' : 'N/D',
                      ),
                      _buildMiniKpiCard(
                        title: 'Inversión Lanzamiento',
                        value: '\$${_formatMoney(launchInv)}',
                      ),
                      _buildMiniKpiCard(
                        title: 'Canibalización Total',
                        value: '\$${_formatMoney(cannibalization)}',
                        color: cannibalization > 0 ? SimcoreColors.danger : null,
                      ),
                      _buildMiniKpiCard(
                        title: 'Ingresos Inc. Totales',
                        value: '\$${_formatMoney(totalRev)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Proyección Mensual de Flujos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  if (periods.isEmpty)
                    const Text('No hay periodos proyectados.')
                  else
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: SimcoreColors.border),
                        color: SimcoreColors.muted,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 20,
                          headingRowColor: WidgetStateProperty.all(SimcoreColors.border.withValues(alpha: 0.3)),
                          columns: const [
                            DataColumn(label: Text('Periodo', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Ingresos Inc.', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('COGS Inc.', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('OpEx Inc.', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('CapEx Inc.', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Canibalización', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Flujo Neto Inc.', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Flujo Acum.', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: periods.map((p) {
                            final netCash = p['netIncrementalCashflow'] ?? 0.0;
                            final cumCash = p['cumulativeCashflow'] ?? 0.0;
                            return DataRow(
                              cells: [
                                DataCell(Text(p['periodLabel'] ?? 'Mes ${p['periodNumber']}')),
                                DataCell(Text('\$${_formatMoney(p['incrementalRevenue'])}')),
                                DataCell(Text('\$${_formatMoney(p['incrementalCogs'])}')),
                                DataCell(Text('\$${_formatMoney(p['incrementalOpex'])}')),
                                DataCell(Text('\$${_formatMoney(p['incrementalCapex'])}')),
                                DataCell(Text('\$${_formatMoney(p['cannibalizationAdj'])}')),
                                DataCell(Text(
                                  '\$${_formatMoney(netCash)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: netCash >= 0 ? SimcoreColors.success : SimcoreColors.danger,
                                  ),
                                )),
                                DataCell(Text(
                                  '\$${_formatMoney(cumCash)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: cumCash >= 0 ? SimcoreColors.success : SimcoreColors.danger,
                                  ),
                                )),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMiniKpiCard({
    required String title,
    required String value,
    bool highlight = false,
    Color? color,
  }) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight ? SimcoreColors.accentSoft.withValues(alpha: 0.3) : SimcoreColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? SimcoreColors.accent : SimcoreColors.border,
          width: highlight ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: SimcoreColors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? (highlight ? SimcoreColors.accent : SimcoreColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMoney(dynamic val) {
    if (val == null) return '0.00';
    final numValue = double.tryParse(val.toString()) ?? 0.0;
    return numValue.toStringAsFixed(2);
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> data) {
    final periods = List<Map<String, dynamic>>.from(
      (data['periods'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _EditIncrementalDialog(
          periods: periods,
          onSave: (updatedPeriods) async {
            final body = {
              'scenarioType': 'PROBABLE',
              'periods': updatedPeriods,
            };
            return await ref.read(saveIncrementalNotifierProvider.notifier).save(body);
          },
        );
      },
    );
  }
}

class _EditIncrementalDialog extends StatefulWidget {
  const _EditIncrementalDialog({
    required this.periods,
    required this.onSave,
  });

  final List<Map<String, dynamic>> periods;
  final Future<bool> Function(List<Map<String, dynamic>>) onSave;

  @override
  State<_EditIncrementalDialog> createState() => _EditIncrementalDialogState();
}

class _EditIncrementalDialogState extends State<_EditIncrementalDialog> {
  final List<Map<String, TextEditingController>> _controllers = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    for (final period in widget.periods) {
      _controllers.add({
        'revenue': TextEditingController(text: (period['incrementalRevenue'] ?? 0).toString()),
        'cogs': TextEditingController(text: (period['incrementalCogs'] ?? 0).toString()),
        'opex': TextEditingController(text: (period['incrementalOpex'] ?? 0).toString()),
        'capex': TextEditingController(text: (period['incrementalCapex'] ?? 0).toString()),
        'cannibalization': TextEditingController(text: (period['cannibalizationAdj'] ?? 0).toString()),
      });
    }
  }

  @override
  void dispose() {
    for (final row in _controllers) {
      for (final ctrl in row.values) {
        ctrl.dispose();
      }
    }
    super.dispose();
  }

  Widget _buildField({required TextEditingController controller, required String label}) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
      style: const TextStyle(fontSize: 13),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 950, maxHeight: 650),
        child: GlassPanel(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const IconTitle(
                    icon: Icons.edit_note_rounded,
                    title: 'Editar Flujos Incrementales (12 Meses)',
                  ),
                  IconButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Modifique los flujos mensuales proyectados. El sistema recalculará el VAN incremental y el impacto en margen.',
                style: TextStyle(color: SimcoreColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.periods.length,
                  itemBuilder: (context, index) {
                    final period = widget.periods[index];
                    final controllers = _controllers[index];

                    return Card(
                      color: SimcoreColors.muted,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: SimcoreColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              period['periodLabel'] ?? 'Mes ${period['periodNumber']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: SimcoreColors.accent,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(child: _buildField(controller: controllers['revenue']!, label: 'Ingresos')),
                                const SizedBox(width: 8),
                                Expanded(child: _buildField(controller: controllers['cogs']!, label: 'COGS')),
                                const SizedBox(width: 8),
                                Expanded(child: _buildField(controller: controllers['opex']!, label: 'OpEx')),
                                const SizedBox(width: 8),
                                Expanded(child: _buildField(controller: controllers['capex']!, label: 'CapEx')),
                                const SizedBox(width: 8),
                                Expanded(child: _buildField(controller: controllers['cannibalization']!, label: 'Canibalización')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  _saving
                      ? const CircularProgressIndicator()
                      : FilledButton.icon(
                          onPressed: () async {
                            setState(() => _saving = true);
                            try {
                              final updatedPeriods = List.generate(widget.periods.length, (index) {
                                final orig = widget.periods[index];
                                final ctrl = _controllers[index];
                                return {
                                  'periodLabel': orig['periodLabel'] ?? 'Mes ${index + 1}',
                                  'periodNumber': orig['periodNumber'] ?? (index + 1),
                                  'incrementalRevenue': double.tryParse(ctrl['revenue']!.text) ?? 0.0,
                                  'incrementalCogs': double.tryParse(ctrl['cogs']!.text) ?? 0.0,
                                  'incrementalOpex': double.tryParse(ctrl['opex']!.text) ?? 0.0,
                                  'incrementalCapex': double.tryParse(ctrl['capex']!.text) ?? 0.0,
                                  'cannibalizationAdj': double.tryParse(ctrl['cannibalization']!.text) ?? 0.0,
                                };
                              });
                              final success = await widget.onSave(updatedPeriods);
                              if (success && mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Flujos incrementales actualizados con éxito.'),
                                    backgroundColor: SimcoreColors.success,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error al guardar: $e'),
                                    backgroundColor: SimcoreColors.danger,
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _saving = false);
                            }
                          },
                          icon: const Icon(Icons.save_rounded),
                          label: const Text('Guardar Flujos'),
                          style: FilledButton.styleFrom(
                            backgroundColor: SimcoreColors.accent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiSimulationPanel extends ConsumerStatefulWidget {
  const _AiSimulationPanel();

  @override
  ConsumerState<_AiSimulationPanel> createState() => _AiSimulationPanelState();
}

class _AiSimulationPanelState extends ConsumerState<_AiSimulationPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _priceCtrl = TextEditingController(text: '100.0');
  final _budgetCtrl = TextEditingController(text: '5000.0');
  String _channel = 'Digital';

  final _vanCtrl = TextEditingController(text: '0.0');

  ({double price, double budget, String channel})? _adoptionArgs;
  double? _stressTestVan;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _priceCtrl.dispose();
    _budgetCtrl.dispose();
    _vanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final incrementalAsync = ref.watch(incrementalAnalysisProvider);
    final van = incrementalAsync.value?['vanIncremental']?.toString() ?? '0.0';
    if (_vanCtrl.text == '0.0' || _vanCtrl.text.isEmpty) {
      _vanCtrl.text = van;
    }

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const IconTitle(
            icon: Icons.psychology_rounded,
            title: 'Simulación Avanzada IA',
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Viabilidad Inicial', icon: Icon(Icons.shield_outlined)),
              Tab(text: 'Curva Adopción Rogers', icon: Icon(Icons.trending_up_rounded)),
              Tab(text: 'Stress Test', icon: Icon(Icons.thunderstorm_rounded)),
            ],
            labelColor: SimcoreColors.accent,
            unselectedLabelColor: SimcoreColors.textSecondary,
            indicatorColor: SimcoreColors.accent,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 380,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildViabilityTab(),
                _buildAdoptionTab(),
                _buildStressTestTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViabilityTab() {
    final viabilityAsync = ref.watch(aiViabilityProvider);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evaluación estratégica de viabilidad financiera del nuevo producto frente a la capacidad instalada y la estructura actual.',
            style: TextStyle(color: SimcoreColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          AiSuggestionCard(
            title: 'Diagnóstico de Viabilidad de Lanzamiento',
            icon: Icons.health_and_safety_rounded,
            suggestionAsync: viabilityAsync,
          ),
        ],
      ),
    );
  }

  Widget _buildAdoptionTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estime la adopción del producto en el mercado usando la teoría de Rogers según su estrategia comercial.',
            style: TextStyle(color: SimcoreColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Precio Unitario (\$)',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _budgetCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Presupuesto Marketing (\$)',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _channel,
                  items: const [
                    DropdownMenuItem(value: 'Digital', child: Text('Digital')),
                    DropdownMenuItem(value: 'Físico', child: Text('Físico')),
                    DropdownMenuItem(value: 'Híbrido', child: Text('Híbrido')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _channel = val);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Canal de Distribución',
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              final price = double.tryParse(_priceCtrl.text) ?? 100.0;
              final budget = double.tryParse(_budgetCtrl.text) ?? 5000.0;
              setState(() {
                _adoptionArgs = (price: price, budget: budget, channel: _channel);
              });
            },
            icon: const Icon(Icons.rocket_launch_rounded),
            label: const Text('Simular Adopción Rogers'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SimcoreColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
          if (_adoptionArgs != null)
            AiSuggestionCard(
              title: 'Curva de Adopción de Rogers e Innovación',
              icon: Icons.trending_up_rounded,
              suggestionAsync: ref.watch(aiAdoptionProvider(_adoptionArgs!)),
            )
          else
            const Card(
              color: SimcoreColors.muted,
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'Presione "Simular Adopción Rogers" para generar las proyecciones.',
                    style: TextStyle(color: SimcoreColors.textTertiary, fontSize: 13),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStressTestTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Someter el lanzamiento a escenarios extremos de estrés económico (inflación o caída en la demanda).',
            style: TextStyle(color: SimcoreColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _vanCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'VAN Proyectado para el Test (\$)',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  final van = double.tryParse(_vanCtrl.text) ?? 0.0;
                  setState(() {
                    _stressTestVan = van;
                  });
                },
                icon: const Icon(Icons.security_rounded),
                label: const Text('Evaluar Sensibilidad'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SimcoreColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_stressTestVan != null)
            AiSuggestionCard(
              title: 'Análisis de Sensibilidad en Escenarios de Estrés',
              icon: Icons.bolt_rounded,
              suggestionAsync: ref.watch(aiStressTestProvider(_stressTestVan!)),
            )
          else
            const Card(
              color: SimcoreColors.muted,
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'Presione "Evaluar Sensibilidad" para iniciar el análisis estratégico.',
                    style: TextStyle(color: SimcoreColors.textTertiary, fontSize: 13),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
