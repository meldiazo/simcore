import 'package:core_sim_ia/app/theme/app_theme.dart';
import 'package:core_sim_ia/features/shared/data/demo/simcore_demo_data.dart';
import 'package:core_sim_ia/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final podium = rankingData.take(3).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageIntro(
          title: 'Ranking Global',
          subtitle:
              'Posicion competitiva final y resultados acumulados del simulador.',
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 20,
          children: [
            _PodiumCard(
                team: podium[1], height: 170, color: const Color(0xFFC9CDD4)),
            _PodiumCard(
                team: podium[0],
                height: 210,
                color: const Color(0xFFFFD76A),
                winner: true),
            _PodiumCard(
                team: podium[2], height: 150, color: const Color(0xFFE0B78E)),
          ],
        ),
        const SizedBox(height: 32),
        ResponsiveSectionWrap(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: const _RankingTablePanel(),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  GlassPanel(
                    backgroundColor:
                        SimcoreColors.accentSoft.withValues(alpha: 0.45),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tu Posicion',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                        SizedBox(height: 10),
                        Text('2 / 5',
                            style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w700,
                                color: SimcoreColors.accent)),
                        SizedBox(height: 6),
                        Text('Subiste 1 posicion frente al C1',
                            style: TextStyle(color: SimcoreColors.success)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Brecha con el Lider',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 10),
                        Text('4.5 puntos',
                            style: GoogleFonts.jetBrainsMono(
                                fontSize: 28, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        const LinearProgressIndicator(
                            value: 0.85, minHeight: 10),
                        const SizedBox(height: 12),
                        const Text(
                            'Estas al 85% de presionar al lider. Optimiza tu C.O.G.S. para cerrar el gap de rentabilidad.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RankingTablePanel extends StatelessWidget {
  const _RankingTablePanel();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 760) {
        return Column(
          children: rankingData.map((team) {
            final isCurrent = team.team == 'Equipo Alpha';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassPanel(
                padding: const EdgeInsets.all(16),
                backgroundColor: isCurrent
                    ? SimcoreColors.accentSoft
                    : SimcoreColors.glass,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${team.rank} ${isCurrent ? '${team.team} · TU' : team.team}',
                      softWrap: true,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    MobileInfoRow(
                        label: 'Puntaje', value: team.score.toStringAsFixed(1)),
                    MobileInfoRow(
                        label: 'Rentabilidad',
                        value: '${team.profitability.toStringAsFixed(1)}%'),
                    MobileInfoRow(
                        label: 'Market Share',
                        value: '${team.marketShare.toStringAsFixed(1)}%'),
                    MobileInfoRow(
                        label: 'Eficiencia',
                        value: '${team.efficiency.toStringAsFixed(1)}%'),
                  ],
                ),
              ),
            );
          }).toList(growable: false),
        );
      }

      return GlassPanel(
        padding: EdgeInsets.zero,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('#')),
            DataColumn(label: Text('Equipo')),
            DataColumn(label: Text('Puntaje')),
            DataColumn(label: Text('Rentabilidad')),
            DataColumn(label: Text('Market Share')),
            DataColumn(label: Text('Eficiencia')),
          ],
          rows: rankingData.map((team) {
            final isCurrent = team.team == 'Equipo Alpha';
            return DataRow(
              cells: [
                DataCell(Text('${team.rank}')),
                DataCell(Text(isCurrent ? '${team.team} · TU' : team.team)),
                DataCell(Text(team.score.toStringAsFixed(1))),
                DataCell(Text('${team.profitability.toStringAsFixed(1)}%')),
                DataCell(Text('${team.marketShare.toStringAsFixed(1)}%')),
                DataCell(Text('${team.efficiency.toStringAsFixed(1)}%')),
              ],
            );
          }).toList(growable: false),
        ),
      );
    });
  }
}

class _PodiumCard extends StatelessWidget {
  const _PodiumCard({
    required this.team,
    required this.height,
    required this.color,
    this.winner = false,
  });

  final RankingTeam team;
  final double height;
  final Color color;
  final bool winner;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (winner)
          const Icon(Icons.emoji_events_rounded,
              color: Color(0xFFE7B92E), size: 34),
        CircleAvatar(
          radius: winner ? 30 : 24,
          backgroundColor: color,
          child: Text('${team.rank}',
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
        ),
        const SizedBox(height: 10),
        Text(team.team,
            style: TextStyle(
                fontWeight: winner ? FontWeight.w700 : FontWeight.w600,
                fontSize: winner ? 18 : 15)),
        Text(team.score.toStringAsFixed(1),
            style: GoogleFonts.jetBrainsMono(
                color: winner
                    ? SimcoreColors.accent
                    : SimcoreColors.textSecondary)),
        const SizedBox(height: 12),
        Container(
          width: winner ? 170 : 145,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.45),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: color.withValues(alpha: 0.75)),
          ),
        ),
      ],
    );
  }
}
