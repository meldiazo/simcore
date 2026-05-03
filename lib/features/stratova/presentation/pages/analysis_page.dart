import 'package:core_sim_ia/app/theme.dart';
import 'package:core_sim_ia/features/stratova/data/stratova_mock_data.dart';
import 'package:core_sim_ia/features/stratova/presentation/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final benchmark = [
      ('Rentabilidad', 18.5, 16.8, 22.1),
      ('Liquidez', 2.4, 2.6, 3.1),
      ('Eficiencia', 87.3, 82.9, 91.5),
      ('Market Share', 14.8, 13.8, 18.3),
      ('Endeudamiento', 45.2, 48.5, 38.9),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageIntro(
          title: 'Analisis General',
          subtitle: 'Consolidacion de KPIs y comparativa con cohorte.',
        ),
        const SizedBox(height: 24),
        const ResponsiveWrap(
          itemWidth: 300,
          children: [
            _SummaryCard(
                title: 'Puntaje General',
                value: '89.7',
                detail: 'Posicion #2 de 5 · +3.3% vs promedio',
                color: StratovaColors.success,
                icon: Icons.workspace_premium_outlined),
            _SummaryCard(
                title: 'Tendencia',
                value: 'Creciente',
                detail: '+2.9 pts ciclo a ciclo',
                color: StratovaColors.accent,
                icon: Icons.trending_up_rounded),
            _SummaryCard(
                title: 'Brecha',
                value: '4.5',
                detail: '-27.4% vs ciclo anterior',
                color: StratovaColors.warning,
                icon: Icons.track_changes_outlined),
          ],
        ),
        const SizedBox(height: 24),
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Evolucion de indicadores',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
              const SizedBox(height: 18),
              ...[
                ('Rentabilidad', [14.2, 16.2, 18.5], StratovaColors.accent),
                ('Eficiencia', [79.5, 82.1, 87.3], StratovaColors.success),
                ('Market Share', [12.4, 13.1, 14.8], StratovaColors.warning),
              ].map((row) => Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child:
                        _TrendRow(label: row.$1, values: row.$2, color: row.$3),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ResponsiveSectionWrap(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Comparativa vs Cohorte',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 18)),
                    const SizedBox(height: 18),
                    ...benchmark.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: Text(item.$1,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600))),
                                  Text(
                                    '${item.$2} / ${item.$3} / ${item.$4}',
                                    style:
                                        GoogleFonts.jetBrainsMono(fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                  value: (item.$2 / item.$4).clamp(0.0, 1.0),
                                  minHeight: 8),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Benchmark Detallado',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 18)),
                    const SizedBox(height: 18),
                    ...rankingData.take(3).map((team) => Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: team.rank == 1
                                    ? const Color(0xFFFFE08A)
                                    : team.rank == 2
                                        ? const Color(0xFFE5E7EB)
                                        : const Color(0xFFF5D0A9),
                                child: Text('${team.rank}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(team.team,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    Text(
                                        'Rent. ${team.profitability}% · Share ${team.marketShare}% · Efic. ${team.efficiency}%'),
                                  ],
                                ),
                              ),
                              Text(team.score.toStringAsFixed(1),
                                  style: GoogleFonts.jetBrainsMono(
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        )),
                    const Divider(),
                    const Text(
                      'Insight IA: el equipo Alpha supera el promedio de la cohorte en rentabilidad y eficiencia, pero aun carga una brecha material de market share frente al lider.',
                      style: TextStyle(
                          height: 1.5, color: StratovaColors.textSecondary),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.detail,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String detail;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                  backgroundColor: color,
                  child: Icon(icon, color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: StratovaColors.textTertiary)),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(detail),
        ],
      ),
    );
  }
}

class _TrendRow extends StatelessWidget {
  const _TrendRow({
    required this.label,
    required this.values,
    required this.color,
  });

  final String label;
  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final max = values.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: values.map((value) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: color.withValues(alpha: value / max),
                  ),
                ),
              ),
            );
          }).toList(growable: false),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: values
              .map((value) => Text(value.toString(),
                  style: GoogleFonts.jetBrainsMono(fontSize: 12)))
              .toList(growable: false),
        ),
      ],
    );
  }
}
