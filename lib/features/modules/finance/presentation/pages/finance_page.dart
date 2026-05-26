import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/shared/data/demo/simcore_demo_data.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  bool showAiPanel = true;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final availableWidth = constraints.maxWidth;
      final useTwoColumns = availableWidth >= 980 && showAiPanel;
      final content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageIntro(
            title: 'Finanzas y Flujo de Caja',
            subtitle: 'Proyecciones interactivas, VPN y estado de resultados.',
            trailing: showAiPanel
                ? null
                : OutlinedButton.icon(
                    onPressed: () => setState(() => showAiPanel = true),
                    icon: const Icon(Icons.smart_toy_outlined),
                    label: const Text('Ver orientación de análisis'),
                  ),
          ),
          const SizedBox(height: 24),
          ResponsiveWrap(
            itemWidth: 260,
            children: const [
              KpiCard(
                  metric: KpiMetric(
                      title: 'Valor Actual Neto',
                      value: 1.25,
                      unit: 'M\$',
                      delta: 12.5,
                      trendUp: true,
                      state: 'success')),
              KpiCard(
                  metric: KpiMetric(
                      title: 'T.I.R.',
                      value: 24.5,
                      unit: '%',
                      delta: 2.1,
                      trendUp: true,
                      state: 'success')),
              KpiCard(
                  metric: KpiMetric(
                      title: 'Payback',
                      value: 2.8,
                      unit: 'A',
                      delta: 0,
                      trendUp: false,
                      state: 'warning')),
              KpiCard(
                  metric: KpiMetric(
                      title: 'WACC Acumulado',
                      value: 10.5,
                      unit: '%',
                      delta: 0,
                      trendUp: true,
                      state: 'neutral')),
            ],
          ),
          const SizedBox(height: 24),
          GlassPanel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: responsivePanelPadding(availableWidth),
                  child: ResponsiveHeaderAction(
                    title: 'Estado de Resultados Pro-Forma',
                    subtitle:
                        'Celdas calculadas automáticamente desde Mercado y Estructuras Organizativas.',
                    action: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text(
                        'Analizar escenarios',
                        softWrap: true,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                _FinanceTable(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ResponsiveSectionWrap(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: _ScenarioCard(),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: _CashflowCard(),
              ),
            ],
          ),
          if (!useTwoColumns && showAiPanel) ...[
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child:
                  _AiPanel(onClose: () => setState(() => showAiPanel = false)),
            ),
          ],
        ],
      );

      return useTwoColumns
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: content),
                const SizedBox(width: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 310),
                  child: _AiPanel(
                      onClose: () => setState(() => showAiPanel = false)),
                ),
              ],
            )
          : content;
    });
  }
}

class _AiPanel extends StatelessWidget {
  const _AiPanel({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderColor: SimcoreColors.accent.withValues(alpha: 0.24),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: SimcoreColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: SimcoreColors.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child:
                      const Icon(Icons.smart_toy_outlined, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Asistente de análisis',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      Text('Pendiente de integración',
                          style: TextStyle(
                              fontSize: 12, color: SimcoreColors.accent)),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: onClose, icon: const Icon(Icons.close_rounded)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _ChatBubble(
                  title: 'Alerta de liquidez',
                  text:
                      'Si mantienes el gasto de marketing y no amplias financiamiento, tu caja libre cae debajo del umbral en 1.4 ciclos.',
                ),
                SizedBox(height: 14),
                _ChatBubble(
                  title: 'Escenario recomendado',
                  text:
                      'Reducir dividendos a cero y reprogramar parte de la inversion mejora el VAN ajustado por riesgo en 8.7%.',
                ),
                SizedBox(height: 14),
                _ChatBubble(
                  title: 'Insight cruzado',
                  text:
                      'La proyeccion de demanda del modulo mercado soporta un incremento de produccion, pero requiere capital de trabajo adicional.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Ingresos Operativos', [1200000, 1350000, 1500000, 1680000], false),
      ('( C.O.G.S. )', [600000, 650000, 700000, 760000], true),
      ('( Gastos administrativos y estructura organizativa )', [250000, 250000, 260000, 260000], true),
      ('( Marketing )', [150000, 150000, 180000, 200000], true),
      ('EBITDA Operativo', [200000, 300000, 360000, 460000], false),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 700) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            constraints.maxWidth < 360 ? 12 : 16,
            0,
            constraints.maxWidth < 360 ? 12 : 16,
            16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rows.map((row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassPanel(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: SimcoreColors.surface,
                  child: LayoutBuilder(builder: (context, cardConstraints) {
                    final tileWidth = ((cardConstraints.maxWidth - 10) / 2)
                        .clamp(110.0, 260.0)
                        .toDouble();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.$1,
                          softWrap: true,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: row.$2.asMap().entries.map((entry) {
                            return SizedBox(
                              width: tileWidth,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border:
                                      Border.all(color: SimcoreColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('T${entry.key + 1}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12)),
                                    const SizedBox(height: 6),
                                    Text('\$${entry.value ~/ 1000}K',
                                        softWrap: true,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(growable: false),
                        ),
                      ],
                    );
                  }),
                ),
              );
            }).toList(growable: false),
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowHeight: 48,
          dataRowMinHeight: 52,
          dataRowMaxHeight: 52,
          columns: const [
            DataColumn(label: Text('Concepto')),
            DataColumn(label: Text('T1')),
            DataColumn(label: Text('T2')),
            DataColumn(label: Text('T3')),
            DataColumn(label: Text('T4')),
          ],
          rows: rows.map((row) {
            return DataRow(
              cells: [
                DataCell(Text(row.$1,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
                ...row.$2.map((value) => DataCell(Text('\$${value ~/ 1000}K'))),
              ],
            );
          }).toList(growable: false),
        ),
      );
    });
  }
}

class _ScenarioCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Simulacion de Escenarios (VAN)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          ...financialScenarios.map((scenario) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: MetricBar(
                  label: scenario.name,
                  value: scenario.profit.toDouble(),
                  max: 2000000,
                  trailing:
                      '\$${(scenario.profit / 1000000).toStringAsFixed(2)}M · ${(scenario.probability * 100).toStringAsFixed(0)}%',
                  color: scenario.name == 'Optimista'
                      ? SimcoreColors.success
                      : scenario.name == 'Base'
                          ? SimcoreColors.accent
                          : SimcoreColors.warning,
                ),
              )),
        ],
      ),
    );
  }
}

class _CashflowCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Inyeccion de Capital vs Quema',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          ...cashFlowEntries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: LayoutBuilder(builder: (context, constraints) {
                  if (constraints.maxWidth < 380) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.month,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text('Operativo \$${entry.operational ~/ 1000}K'),
                        Text('Inversion \$${entry.investment ~/ 1000}K'),
                        Text(
                          'Financ. \$${entry.financing ~/ 1000}K',
                          style: TextStyle(
                              color: entry.financing < 0
                                  ? SimcoreColors.warning
                                  : SimcoreColors.textSecondary),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                          child: Text(entry.month,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600))),
                      Expanded(
                          child: Text(
                              'Operativo \$${entry.operational ~/ 1000}K')),
                      Expanded(
                          child:
                              Text('Inversion \$${entry.investment ~/ 1000}K')),
                      Expanded(
                        child: Text(
                          'Financ. \$${entry.financing ~/ 1000}K',
                          style: TextStyle(
                              color: entry.financing < 0
                                  ? SimcoreColors.warning
                                  : SimcoreColors.textSecondary),
                        ),
                      ),
                    ],
                  );
                }),
              )),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SimcoreColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SimcoreColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(text,
              style: const TextStyle(
                  color: SimcoreColors.textSecondary, height: 1.4)),
        ],
      ),
    );
  }
}
