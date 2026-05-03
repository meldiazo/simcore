import 'package:core_sim_ia/app/theme.dart';
import 'package:core_sim_ia/features/stratova/data/stratova_mock_data.dart';
import 'package:core_sim_ia/features/stratova/presentation/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool simulationRunning = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageIntro(
          title: 'Panel de Control Docente',
          subtitle:
              'Auditoria de simulaciones, control de tiempo e inyeccion de eventos macroeconomicos.',
          trailing: AdaptiveActionRow(
            children: [
              OutlinedButton(
                onPressed: () {},
                child: const Text('Exportar CSV'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: StratovaColors.danger),
                onPressed: () {},
                icon: const Icon(Icons.fast_forward_rounded),
                label: const Text('Forzar Cierre de Ciclo'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ResponsiveSectionWrap(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: const _AdminTeamsPanel(),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Control de Reloj (Servidor)',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            '14:32:05',
                            style: GoogleFonts.jetBrainsMono(
                                fontSize: 40, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.tonalIcon(
                                onPressed: () =>
                                    setState(() => simulationRunning = true),
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('Ejecutando'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.tonalIcon(
                                onPressed: () =>
                                    setState(() => simulationRunning = false),
                                style: FilledButton.styleFrom(
                                  backgroundColor: simulationRunning
                                      ? StratovaColors.muted
                                      : StratovaColors.dangerSoft,
                                ),
                                icon: const Icon(
                                    Icons.pause_circle_outline_rounded),
                                label: const Text('Pausar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Inyector de Crisis',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                        SizedBox(height: 10),
                        Text(
                            'Activa eventos globales que afectan instantaneamente los modelos de todos los equipos.'),
                        SizedBox(height: 16),
                        _ToggleRow(
                            label: 'Inflacion Abrupta (+8%)', enabled: false),
                        SizedBox(height: 12),
                        _ToggleRow(
                            label: 'Huelga de Transportistas', enabled: true),
                        SizedBox(height: 12),
                        _ToggleRow(label: 'Boom Tecnologico', enabled: false),
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

class _AdminTeamsPanel extends StatelessWidget {
  const _AdminTeamsPanel();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 700) {
        return Column(
          children: adminTeams.map((team) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassPanel(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(team.name,
                        softWrap: true,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    MobileInfoRow(label: 'Miembros', value: '${team.users}'),
                    MobileInfoRow(
                      label: 'Estado',
                      value: team.isReady
                          ? 'Decisiones enviadas'
                          : 'Editando borrador',
                    ),
                    MobileInfoRow(label: 'Actividad', value: team.lastLogin),
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
            DataColumn(label: Text('Empresa')),
            DataColumn(label: Text('Miembros')),
            DataColumn(label: Text('Estado')),
            DataColumn(label: Text('Ultima actividad')),
          ],
          rows: adminTeams.map((team) {
            return DataRow(
              cells: [
                DataCell(Text(team.name,
                    style: const TextStyle(fontWeight: FontWeight.w700))),
                DataCell(Text('${team.users}')),
                DataCell(
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: team.isReady
                          ? StratovaColors.successSoft
                          : StratovaColors.warningSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      team.isReady
                          ? 'Decisiones enviadas'
                          : 'Editando borrador',
                      style: TextStyle(
                          color: team.isReady
                              ? StratovaColors.success
                              : StratovaColors.warning),
                    ),
                  ),
                ),
                DataCell(Text(team.lastLogin)),
              ],
            );
          }).toList(growable: false),
        ),
      );
    });
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.enabled,
  });

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: enabled
            ? StratovaColors.accentSoft.withValues(alpha: 0.4)
            : StratovaColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: enabled
                ? StratovaColors.accent.withValues(alpha: 0.2)
                : StratovaColors.border),
      ),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontWeight:
                          enabled ? FontWeight.w700 : FontWeight.w500))),
          Switch(value: enabled, onChanged: (_) {}),
        ],
      ),
    );
  }
}
