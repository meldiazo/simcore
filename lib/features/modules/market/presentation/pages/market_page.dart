import 'dart:math' as math;

import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/shared/data/demo/simcore_demo_data.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  double price = 1250;
  double marketing = 450000;

  int get baseDemand {
    final demand = 98000 * (1250 / price) * (1 + (marketing / 2000000));
    return demand.round();
  }

  @override
  Widget build(BuildContext context) {
    final pessimistic = (baseDemand * 0.85).round();
    final optimistic = (baseDemand * 1.15).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageIntro(
          title: 'Modulo Mercado',
          subtitle:
              'Simulacion de demanda, analisis competitivo e ingesta de datos.',
          trailing: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.table_chart_outlined),
            label: const Text('Ingestar Estudio (CSV)'),
          ),
        ),
        const SizedBox(height: 24),
        ResponsiveWrap(
          children: [
            const KpiCard(
                metric: KpiMetric(
                    title: 'Tamano del Mercado',
                    value: 42.5,
                    unit: 'M\$',
                    delta: 6.8,
                    trendUp: true,
                    state: 'success')),
            KpiCard(
                metric: KpiMetric(
                    title: 'Presupuesto Competitivo',
                    value: marketing,
                    unit: '\$',
                    delta: 0,
                    trendUp: true,
                    state: 'neutral')),
            const KpiCard(
                metric: KpiMetric(
                    title: 'Elasticidad Proyectada',
                    value: -1.2,
                    unit: 'b',
                    delta: 0,
                    trendUp: false,
                    state: 'warning')),
            KpiCard(
                metric: KpiMetric(
                    title: 'Forecast Base',
                    value: baseDemand / 1000,
                    unit: 'K',
                    delta: ((baseDemand / 98000) - 1) * 100,
                    trendUp: baseDemand >= 98000,
                    state: baseDemand >= 98000 ? 'success' : 'danger')),
          ],
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const IconTitle(
                      icon: Icons.smart_toy_outlined,
                      title: 'Simulador de Precios',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                        'Ajusta variables y el motor de IA calculara la cuota estimada en tiempo real.'),
                    const SizedBox(height: 24),
                    _SliderField(
                      label: 'Precio Promedio',
                      value: price,
                      min: 800,
                      max: 2000,
                      format: (value) => '\$${value.round()}',
                      onChanged: (value) => setState(() => price = value),
                    ),
                    const SizedBox(height: 24),
                    _SliderField(
                      label: 'Presupuesto Marketing',
                      value: marketing,
                      min: 0,
                      max: 1000000,
                      format: (value) => '\$${value.round()}',
                      onChanged: (value) => setState(() => marketing = value),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () {},
                      child: const Text('Guardar Decision de Mercado'),
                    ),
                  ],
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 890),
              child: GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveHeaderAction(
                      title: 'Proyeccion de Demanda',
                      subtitle:
                          'Distribucion probabilistica basada en elasticidad precio-demanda.',
                      action: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: SimcoreColors.surface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: SimcoreColors.border),
                        ),
                        child: const Text('Confianza: 82%',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _DemandChart(
                        pessimistic: pessimistic,
                        base: baseDemand,
                        optimistic: optimistic),
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 410),
                          child: GlassPanel(
                            backgroundColor: SimcoreColors.surface,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Segmentos del mercado',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 16),
                                ...marketSegments.map((segment) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: MetricBar(
                                        label:
                                            '${segment.name} · ${segment.competition}',
                                        value: segment.size.toDouble(),
                                        max: 100,
                                        trailing:
                                            '${segment.size}% · ${segment.growth.toStringAsFixed(1)}%',
                                        color: segment.name == 'Premium'
                                            ? SimcoreColors.accent
                                            : segment.name == 'Media'
                                                ? SimcoreColors.success
                                                : SimcoreColors.warning,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 410),
                          child: GlassPanel(
                            backgroundColor: SimcoreColors.surface,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Mapa competitivo',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 16),
                                ...competitors.map((competitor) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 14),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: SimcoreColors.accentSoft,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                                Icons.business_center_outlined,
                                                color: SimcoreColors.accent),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(competitor.name,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700)),
                                                const SizedBox(height: 4),
                                                Text(competitor.strategy),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '${competitor.share.toStringAsFixed(1)}%',
                                            style: GoogleFonts.jetBrainsMono(
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SliderField extends StatelessWidget {
  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.format,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String Function(double value) format;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
            Text(format(value),
                style: GoogleFonts.jetBrainsMono(
                    fontWeight: FontWeight.w700, color: SimcoreColors.accent)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 6,
          children: [
            Text(format(min),
                style: const TextStyle(
                    fontSize: 12, color: SimcoreColors.textTertiary)),
            Text(format(max),
                style: const TextStyle(
                    fontSize: 12, color: SimcoreColors.textTertiary)),
          ],
        ),
      ],
    );
  }
}

class _DemandChart extends StatelessWidget {
  const _DemandChart({
    required this.pessimistic,
    required this.base,
    required this.optimistic,
  });

  final int pessimistic;
  final int base;
  final int optimistic;

  @override
  Widget build(BuildContext context) {
    final values = [pessimistic, base, optimistic];
    final maxValue = values.reduce(math.max).toDouble();
    final labels = ['Pesimista', 'Base', 'Optimista'];
    final colors = [
      SimcoreColors.warning,
      SimcoreColors.accent,
      SimcoreColors.success
    ];

    return SizedBox(
      height: 280,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (index) {
          final value = values[index];
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${(value / 1000).toStringAsFixed(0)}k',
                      style: GoogleFonts.jetBrainsMono(
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        width: 120,
                        height: 180 * (value / maxValue),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              colors[index].withValues(alpha: 0.85),
                              colors[index].withValues(alpha: 0.25)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(labels[index],
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
