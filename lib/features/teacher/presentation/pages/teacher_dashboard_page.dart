import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/features/teacher/data/models/evaluation_model.dart';
import 'package:simcore_frontend/features/teacher/data/models/intervention_model.dart';
import 'package:simcore_frontend/features/teacher/data/models/teacher_dashboard_model.dart';
import 'package:simcore_frontend/features/teacher/presentation/providers/evaluation_providers.dart';
import 'package:simcore_frontend/features/teacher/presentation/providers/intervention_providers.dart';
import 'package:simcore_frontend/features/teacher/presentation/providers/teacher_dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeacherDashboardPage extends ConsumerWidget {
  const TeacherDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(teacherDashboardProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageIntro(
          title: 'Panel de Control Docente',
          subtitle: 'Seguimiento de grupos, empresas y progreso de módulos.',
        ),
        const SizedBox(height: 24),
        dashboardAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => GlassPanel(
            child: Text('Error al cargar dashboard: $e',
                style: const TextStyle(color: SimcoreColors.danger)),
          ),
          data: (dashboard) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary KPIs
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  _StatTile(
                      label: 'Total grupos', value: '${dashboard.totalGroups}'),
                  _StatTile(
                    label: 'Empresas activas',
                    value: '${dashboard.activeCompanies}',
                    color: SimcoreColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Groups list
              if (dashboard.groups.isEmpty)
                const GlassPanel(
                  child: Center(
                    child: Text(
                      'Sin grupos registrados en este curso.',
                      style: TextStyle(color: SimcoreColors.textSecondary),
                    ),
                  ),
                )
              else
                ...dashboard.groups.map(
                  (group) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _GroupCard(group: group),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GroupCard extends ConsumerStatefulWidget {
  const _GroupCard({required this.group});

  final GroupDashboardItem group;

  @override
  ConsumerState<_GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends ConsumerState<_GroupCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final evaluationAsync = ref.watch(groupEvaluationProvider(group.groupId));
    final interventionsAsync = group.companyId == null
        ? null
        : ref.watch(companyInterventionsProvider(group.companyId!));
    final incoherenceTotal = group.incoherences['total'] as int? ?? 0;
    final incoherenceHigh = group.incoherences['high'] as int? ?? 0;

    final companyStatus = group.companyStatus != null
        ? CompanyStatus.fromApi(group.companyStatus!)
        : null;

    final (statusColor, statusBg) = switch (companyStatus) {
      CompanyStatus.inSimulation => (
          SimcoreColors.success,
          SimcoreColors.successSoft
        ),
      CompanyStatus.closed => (SimcoreColors.danger, SimcoreColors.dangerSoft),
      CompanyStatus.draft => (
          SimcoreColors.textTertiary,
          SimcoreColors.surface
        ),
      _ => (SimcoreColors.textTertiary, SimcoreColors.surface),
    };

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.groupName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      if (group.companyName != null)
                        Text(
                          group.companyName!,
                          style: const TextStyle(
                            color: SimcoreColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (group.companyStatus != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      companyStatus?.label ?? '',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: SimcoreColors.textTertiary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(
                icon: Icons.check_circle_outline_rounded,
                label: '${group.completedModules} módulos completos',
                color: SimcoreColors.success,
              ),
              if (incoherenceTotal > 0)
                _Chip(
                  icon: Icons.warning_amber_rounded,
                  label:
                      '$incoherenceTotal incoherencias ($incoherenceHigh alta)',
                  color: incoherenceHigh > 0
                      ? SimcoreColors.danger
                      : SimcoreColors.warning,
                ),
              evaluationAsync.maybeWhen(
                data: (evaluation) => evaluation?.totalScore != null
                    ? _Chip(
                        icon: Icons.grade_rounded,
                        label:
                            'Nota ${evaluation!.totalScore!.toStringAsFixed(1)}',
                        color: SimcoreColors.accent,
                      )
                    : const SizedBox.shrink(),
                orElse: () => const SizedBox.shrink(),
              ),
              interventionsAsync?.maybeWhen(
                    data: (interventions) => interventions.isNotEmpty
                        ? _Chip(
                            icon: Icons.bolt_rounded,
                            label: '${interventions.length} intervenciones',
                            color: SimcoreColors.warning,
                          )
                        : const SizedBox.shrink(),
                    orElse: () => const SizedBox.shrink(),
                  ) ??
                  const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (group.companyId != null)
                  OutlinedButton.icon(
                    onPressed: () => _openInterventionSheet(context, group),
                    icon: const Icon(Icons.bolt_outlined, size: 18),
                    label: const Text('Intervenir'),
                  ),
                OutlinedButton.icon(
                  onPressed: () => _openEvaluationSheet(
                    context,
                    group,
                    evaluationAsync.valueOrNull,
                  ),
                  icon: const Icon(Icons.fact_check_outlined, size: 18),
                  label: Text(
                    evaluationAsync.valueOrNull == null
                        ? 'Evaluar'
                        : 'Editar evaluación',
                  ),
                ),
              ],
            ),
          ),
          if (_expanded && group.moduleProgress.isNotEmpty) ...[
            const Divider(height: 20),
            const Text(
              'Detalle de módulos',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: SimcoreColors.textSecondary),
            ),
            const SizedBox(height: 10),
            ...group.moduleProgress.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.circle,
                          size: 8, color: SimcoreColors.textTertiary),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(
                        m['module']?.toString() ?? '',
                        style: const TextStyle(fontSize: 13),
                      )),
                      Text(
                        m['status'] != null
                            ? ModuleStatus.fromApi(m['status'].toString()).label
                            : '',
                        style: const TextStyle(
                            fontSize: 12, color: SimcoreColors.textSecondary),
                      ),
                    ],
                  ),
                )),
            if (interventionsAsync != null) ...[
              const SizedBox(height: 12),
              interventionsAsync.when(
                loading: () => const LinearProgressIndicator(minHeight: 2),
                error: (_, __) => const SizedBox.shrink(),
                data: (interventions) => interventions.isEmpty
                    ? const SizedBox.shrink()
                    : _InterventionHistory(interventions: interventions),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _openEvaluationSheet(
    BuildContext context,
    GroupDashboardItem group,
    EvaluationModel? evaluation,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EvaluationSheet(
        group: group,
        evaluation: evaluation,
      ),
    );
  }

  Future<void> _openInterventionSheet(
    BuildContext context,
    GroupDashboardItem group,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InterventionSheet(group: group),
    );
  }
}

const _interventionTypeOptions = [
  _InterventionTypeOption(
    id: 'TENSION_QUESTION',
    label: 'Pregunta de tensión',
    icon: Icons.help_outline_rounded,
    color: SimcoreColors.accent,
    hint: '¿Pueden justificar por qué eligieron esa estructura de costos?',
  ),
  _InterventionTypeOption(
    id: 'REVISION_ALERT',
    label: 'Alerta de revisión',
    icon: Icons.warning_amber_rounded,
    color: SimcoreColors.warning,
    hint:
        'El sistema detectó una posible incoherencia entre mercado e inversión.',
  ),
  _InterventionTypeOption(
    id: 'RESTRICTION',
    label: 'Restricción nueva',
    icon: Icons.shield_outlined,
    color: SimcoreColors.danger,
    hint:
        'A partir de este punto, el acceso a financiamiento queda restringido.',
  ),
  _InterventionTypeOption(
    id: 'SCENARIO_SHOCK',
    label: 'Shock de escenario',
    icon: Icons.flash_on_rounded,
    color: SimcoreColors.success,
    hint: 'Se ha modificado la tasa de interés de mercado para este ciclo.',
  ),
];

const _targetModuleOptions = [
  null,
  'MARKET',
  'INVESTMENT',
  'FINANCING',
  'ORGANIZATION',
  'ACCOUNTING',
  'ANALYSIS',
];

class _InterventionTypeOption {
  const _InterventionTypeOption({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.hint,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final String hint;
}

class _InterventionSheet extends ConsumerStatefulWidget {
  const _InterventionSheet({required this.group});

  final GroupDashboardItem group;

  @override
  ConsumerState<_InterventionSheet> createState() => _InterventionSheetState();
}

class _InterventionSheetState extends ConsumerState<_InterventionSheet> {
  String _type = _interventionTypeOptions.first.id;
  String? _targetModule;
  late final TextEditingController _messageController;

  _InterventionTypeOption get _selectedType {
    return _interventionTypeOptions.firstWhere((option) => option.id == _type);
  }

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final companyId = widget.group.companyId;
    if (companyId == null) return;

    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La intervención necesita un mensaje.'),
          backgroundColor: SimcoreColors.warning,
        ),
      );
      return;
    }

    final success =
        await ref.read(interventionNotifierProvider.notifier).create(
              companyId: companyId,
              request: CreateInterventionRequest(
                type: _type,
                message: message,
                targetModule: _targetModule,
              ),
            );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Intervención registrada.'
              : 'No se pudo registrar la intervención.',
        ),
        backgroundColor: success ? SimcoreColors.success : SimcoreColors.danger,
      ),
    );
    if (success) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(interventionNotifierProvider).isLoading;

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: SimcoreColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              20 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Nueva intervención',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.group.companyName ?? widget.group.groupName,
                  style: const TextStyle(color: SimcoreColors.textSecondary),
                ),
                const SizedBox(height: 18),
                const Text('Tipo',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _interventionTypeOptions.map((option) {
                    final selected = option.id == _type;
                    return ChoiceChip(
                      selected: selected,
                      avatar: Icon(
                        option.icon,
                        size: 16,
                        color: selected
                            ? option.color
                            : SimcoreColors.textTertiary,
                      ),
                      label: Text(option.label),
                      onSelected: (_) => setState(() => _type = option.id),
                    );
                  }).toList(growable: false),
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<String?>(
                  initialValue: _targetModule,
                  decoration: InputDecoration(
                    labelText: 'Módulo objetivo',
                    filled: true,
                    fillColor: SimcoreColors.muted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items: _targetModuleOptions
                      .map(
                        (module) => DropdownMenuItem<String?>(
                          value: module,
                          child: Text(module ?? 'General'),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) => setState(() => _targetModule = value),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _messageController,
                  minLines: 4,
                  maxLines: 6,
                  maxLength: 2000,
                  decoration: InputDecoration(
                    labelText: 'Mensaje',
                    hintText: _selectedType.hint,
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: SimcoreColors.muted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isSaving ? null : _save,
                    icon: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.bolt_outlined),
                    label: const Text('Registrar intervención'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InterventionHistory extends StatelessWidget {
  const _InterventionHistory({required this.interventions});

  final List<InterventionModel> interventions;

  @override
  Widget build(BuildContext context) {
    final recent = interventions.take(3).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Intervenciones recientes',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: SimcoreColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        ...recent.map((intervention) {
          final option = _interventionTypeOptions.firstWhere(
            (option) => option.id == intervention.type,
            orElse: () => _interventionTypeOptions.first,
          );
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: option.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: option.color.withValues(alpha: 0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(option.icon, size: 16, color: option.color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        option.label,
                        style: TextStyle(
                          color: option.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (intervention.targetModule != null)
                      Text(
                        intervention.targetModule!,
                        style: const TextStyle(
                          color: SimcoreColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  intervention.message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(height: 1.35),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _EvaluationSheet extends ConsumerStatefulWidget {
  const _EvaluationSheet({
    required this.group,
    this.evaluation,
  });

  final GroupDashboardItem group;
  final EvaluationModel? evaluation;

  @override
  ConsumerState<_EvaluationSheet> createState() => _EvaluationSheetState();
}

class _EvaluationSheetState extends ConsumerState<_EvaluationSheet> {
  late double _marketScore;
  late double _investScore;
  late double _orgScore;
  late double _accountScore;
  late double _analysisScore;
  late double _oralScore;
  late double _coherenceScore;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final evaluation = widget.evaluation;
    _marketScore = evaluation?.marketScore ?? 0;
    _investScore = evaluation?.investScore ?? 0;
    _orgScore = evaluation?.orgScore ?? 0;
    _accountScore = evaluation?.accountScore ?? 0;
    _analysisScore = evaluation?.analysisScore ?? 0;
    _oralScore = evaluation?.oralScore ?? 0;
    _coherenceScore = evaluation?.coherenceScore ?? 0;
    _notesController = TextEditingController(text: evaluation?.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _average {
    final values = [
      _marketScore,
      _investScore,
      _orgScore,
      _accountScore,
      _analysisScore,
      _oralScore,
      _coherenceScore,
    ];
    return values.reduce((a, b) => a + b) / values.length;
  }

  Future<void> _save() async {
    final success = await ref.read(evaluationNotifierProvider.notifier).save(
          groupId: widget.group.groupId,
          request: UpsertEvaluationRequest(
            companyId: widget.group.companyId,
            marketScore: _marketScore,
            investScore: _investScore,
            orgScore: _orgScore,
            accountScore: _accountScore,
            analysisScore: _analysisScore,
            oralScore: _oralScore,
            coherenceScore: _coherenceScore,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          ),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Evaluación guardada.'
              : 'No se pudo guardar la evaluación.',
        ),
        backgroundColor: success ? SimcoreColors.success : SimcoreColors.danger,
      ),
    );
    if (success) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(evaluationNotifierProvider).isLoading;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: SimcoreColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              20 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Evaluación del grupo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.group.groupName,
                  style: const TextStyle(color: SimcoreColors.textSecondary),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: SimcoreColors.accentSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Promedio: ${_average.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: SimcoreColors.accent,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _ScoreSlider(
                  label: 'Mercado',
                  value: _marketScore,
                  onChanged: (value) => setState(() => _marketScore = value),
                ),
                _ScoreSlider(
                  label: 'Inversión y financiamiento',
                  value: _investScore,
                  onChanged: (value) => setState(() => _investScore = value),
                ),
                _ScoreSlider(
                  label: 'Organización',
                  value: _orgScore,
                  onChanged: (value) => setState(() => _orgScore = value),
                ),
                _ScoreSlider(
                  label: 'Contabilidad',
                  value: _accountScore,
                  onChanged: (value) => setState(() => _accountScore = value),
                ),
                _ScoreSlider(
                  label: 'Análisis',
                  value: _analysisScore,
                  onChanged: (value) => setState(() => _analysisScore = value),
                ),
                _ScoreSlider(
                  label: 'Defensa oral',
                  value: _oralScore,
                  onChanged: (value) => setState(() => _oralScore = value),
                ),
                _ScoreSlider(
                  label: 'Coherencia global',
                  value: _coherenceScore,
                  onChanged: (value) => setState(() => _coherenceScore = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Notas docentes',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: SimcoreColors.muted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isSaving ? null : _save,
                    icon: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text('Guardar evaluación'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScoreSlider extends StatelessWidget {
  const _ScoreSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                value.toStringAsFixed(0),
                style: const TextStyle(
                  color: SimcoreColors.accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(0, 100),
            min: 0,
            max: 100,
            divisions: 20,
            label: value.toStringAsFixed(0),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(
      {required this.label,
      required this.value,
      this.color = SimcoreColors.accent});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: SimcoreColors.textTertiary)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
