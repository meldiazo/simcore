import 'package:core_sim_ia/app/theme/app_theme.dart';
import 'package:core_sim_ia/features/shared/data/demo/simcore_demo_data.dart';
import 'package:core_sim_ia/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HrPage extends StatefulWidget {
  const HrPage({super.key});

  @override
  State<HrPage> createState() => _HrPageState();
}

class _HrPageState extends State<HrPage> {
  int hiringCount = 0;

  @override
  Widget build(BuildContext context) {
    final projectedPayroll = 154166 + (hiringCount * 2500);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageIntro(
          title: 'Modulo Organizacional (RRHH)',
          subtitle:
              'Diseno de estructura, contrataciones y simulacion de nomina.',
        ),
        const SizedBox(height: 24),
        ResponsiveWrap(
          children: [
            KpiCard(
                metric: KpiMetric(
                    title: 'Headcount Total',
                    value: 145 + hiringCount.toDouble(),
                    unit: 'pax',
                    delta: 5.2,
                    trendUp: true,
                    state: 'neutral')),
            const KpiCard(
                metric: KpiMetric(
                    title: 'Productividad Media',
                    value: 87.3,
                    unit: '%',
                    delta: 3.8,
                    trendUp: true,
                    state: 'success')),
            KpiCard(
                metric: KpiMetric(
                    title: 'Costo Laboral Proyectado',
                    value: projectedPayroll.toDouble(),
                    unit: '\$',
                    delta: 0,
                    trendUp: true,
                    state: 'warning')),
            const KpiCard(
                metric: KpiMetric(
                    title: 'Eficiencia Estructural',
                    value: 82.4,
                    unit: 'pts',
                    delta: 1.2,
                    trendUp: false,
                    state: 'danger')),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const IconTitle(
                      icon: Icons.account_tree_outlined,
                      title: 'Editor de Organigrama',
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 32,
                      runSpacing: 24,
                      children: const [
                        _OrgNode('CEO / Dir. General', primary: true),
                        _OrgNode('Dir. Finanzas'),
                        _OrgNode('Dir. RRHH'),
                        _OrgNode('Dir. Operaciones'),
                        _OrgNode('Planta y Logistica', dashed: true),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GlassPanel(
                      backgroundColor: SimcoreColors.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Simulador rapido de contratacion',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              IconButton.filledTonal(
                                onPressed: () => setState(() => hiringCount =
                                    hiringCount == 0 ? 0 : hiringCount - 1),
                                icon: const Icon(Icons.remove_rounded),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text('Contratar $hiringCount pax',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                ),
                              ),
                              IconButton.filled(
                                onPressed: () =>
                                    setState(() => hiringCount += 1),
                                icon: const Icon(Icons.add_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Gasto estimado Mes 1: \$${projectedPayroll.toString()}',
                            style: GoogleFonts.jetBrainsMono(
                                fontWeight: FontWeight.w700,
                                color: SimcoreColors.accent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Candidatos sugeridos por IA',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                        SizedBox(height: 16),
                        _CandidateTile(
                            name: 'Carlos Mendoza',
                            role: 'Especialista Financiero',
                            salary: '\$2,500/m'),
                        _CandidateTile(
                            name: 'Ana Torres',
                            role: 'Jefe de Planta',
                            salary: '\$3,200/m'),
                        _CandidateTile(
                            name: 'Luis Vargas',
                            role: 'Analista de Datos',
                            salary: '\$2,100/m'),
                        _CandidateTile(
                            name: 'Sofia Robles',
                            role: 'Coordinador de Marketing',
                            salary: '\$2,800/m'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GlassPanel(
                    backgroundColor:
                        SimcoreColors.warningSoft.withValues(alpha: 0.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: SimcoreColors.warning),
                            SizedBox(width: 8),
                            Text('Ineficiencias detectadas',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...organizationalInefficiencies.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.area,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(item.issue),
                                  const SizedBox(height: 4),
                                  Text(item.impact,
                                      style: const TextStyle(
                                          color: SimcoreColors.warning)),
                                ],
                              ),
                            )),
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

class _OrgNode extends StatelessWidget {
  const _OrgNode(this.label, {this.primary = false, this.dashed = false});

  final String label;
  final bool primary;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: primary ? SimcoreColors.accent : SimcoreColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: dashed ? SimcoreColors.textTertiary : SimcoreColors.border,
          style: dashed ? BorderStyle.solid : BorderStyle.solid,
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: primary ? Colors.white : SimcoreColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({
    required this.name,
    required this.role,
    required this.salary,
  });

  final String name;
  final String role;
  final String salary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SimcoreColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SimcoreColors.border),
        ),
        child: Row(
          children: [
            const CircleAvatar(
                backgroundColor: SimcoreColors.accentSoft,
                child: Icon(Icons.person_outline_rounded,
                    color: SimcoreColors.accent)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(role,
                      style: const TextStyle(
                          fontSize: 12, color: SimcoreColors.textTertiary)),
                ],
              ),
            ),
            Flexible(
              child: Text(
                salary,
                textAlign: TextAlign.end,
                softWrap: true,
                style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
