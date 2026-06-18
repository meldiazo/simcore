import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/features/simulation/scenario/domain/entities/scenario.dart';
import 'package:simcore_frontend/features/simulation/scenario/presentation/providers/scenario_providers.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';
import 'package:simcore_frontend/features/academic/presentation/providers/academic_providers.dart';
import 'package:google_fonts/google_fonts.dart';

class ScenarioManagerPage extends ConsumerWidget {
  const ScenarioManagerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simulationContext =
        ref.watch(simulationContextNotifierProvider).context;
    final contextCourseId = simulationContext?.courseId;
    final selectedCourseId = ref.watch(selectedScenarioCourseIdProvider);
    final effectiveCourseId = contextCourseId ?? selectedCourseId;
    final coursesAsync =
        contextCourseId == null ? ref.watch(coursesProvider) : null;
    final scenariosAsync = effectiveCourseId == null
        ? const AsyncValue<List<Scenario>>.data([])
        : ref.watch(scenariosByCourseIdProvider(effectiveCourseId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageIntro(
          title: 'Gestión de Escenarios',
          subtitle: 'Crea, activa y asigna escenarios a los grupos del curso.',
          trailing: FilledButton.icon(
            onPressed: effectiveCourseId == null
                ? null
                : () => _showCreateDialog(context, ref, effectiveCourseId),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nuevo escenario'),
          ),
        ),
        if (coursesAsync != null) ...[
          const SizedBox(height: 12),
          coursesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => GlassPanel(
              child: Text('Error al cargar cursos: $e',
                  style: const TextStyle(color: SimcoreColors.danger)),
            ),
            data: (courses) {
              if (courses.isEmpty) {
                return const GlassPanel(
                  child: Text(
                    'Primero crea un curso para gestionar escenarios.',
                    style: TextStyle(color: SimcoreColors.warning),
                  ),
                );
              }

              final ids = courses
                  .map((c) => (c['id'] as num?)?.toInt())
                  .whereType<int>()
                  .toList();
              final currentValue =
                  ids.contains(selectedCourseId) ? selectedCourseId : ids.first;

              if (selectedCourseId == null && currentValue != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(selectedScenarioCourseIdProvider.notifier).state =
                      currentValue;
                });
              }

              return DropdownButtonFormField<int>(
                initialValue: currentValue,
                decoration: const InputDecoration(labelText: 'Curso'),
                items: courses.map((c) {
                  final id = (c['id'] as num?)?.toInt() ?? 0;
                  final name = (c['name'] ?? c['title'] ?? '').toString();
                  final code = (c['code'] ?? '').toString();
                  final label = code.isEmpty ? name : '$name ($code)';
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  ref.read(selectedScenarioCourseIdProvider.notifier).state =
                      value;
                },
              );
            },
          ),
        ],
        const SizedBox(height: 24),
        scenariosAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => GlassPanel(
            child: Text('Error: $e',
                style: const TextStyle(color: SimcoreColors.danger)),
          ),
          data: (scenarios) {
            if (scenarios.isEmpty) {
              return const GlassPanel(
                child: Center(
                  child: Text(
                    'No hay escenarios creados para este curso.',
                    style: TextStyle(color: SimcoreColors.textSecondary),
                  ),
                ),
              );
            }
            return Column(
              children: scenarios
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ScenarioCard(
                          scenario: s,
                          onActivate: () => ref
                              .read(scenarioFormNotifierProvider.notifier)
                              .activateScenario(s.id),
                          onDeactivate: () => ref
                              .read(scenarioFormNotifierProvider.notifier)
                              .deactivateScenario(s.id),
                          onAssign: () => _showAssignDialog(
                              context, ref, s.id, effectiveCourseId),
                          onAdvanced: () => _showAdvancedSheet(context, s),
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref, int courseId) {
    showDialog(
      context: context,
      builder: (_) => _CreateScenarioDialog(
        courseId: courseId,
        onCreated: () => ref.invalidate(scenariosByCourseProvider),
      ),
    );
  }

  void _showAssignDialog(
    BuildContext context,
    WidgetRef ref,
    int scenarioId,
    int? courseId,
  ) {
    if (courseId == null || courseId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo determinar el curso actual.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => _AssignScenarioDialog(
        scenarioId: scenarioId,
        courseId: courseId,
      ),
    );
  }

  void _showAdvancedSheet(BuildContext context, Scenario scenario) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AdvancedScenarioSheet(scenario: scenario),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({
    required this.scenario,
    required this.onActivate,
    required this.onDeactivate,
    required this.onAssign,
    required this.onAdvanced,
  });

  final Scenario scenario;
  final VoidCallback onActivate;
  final VoidCallback onDeactivate;
  final VoidCallback onAssign;
  final VoidCallback onAdvanced;

  @override
  Widget build(BuildContext context) {
    final (chipColor, chipBg) = switch (scenario.type) {
      ScenarioType.probable => (SimcoreColors.accent, SimcoreColors.accentSoft),
      ScenarioType.optimistic => (
          SimcoreColors.success,
          SimcoreColors.successSoft
        ),
      ScenarioType.pessimistic => (
          SimcoreColors.danger,
          SimcoreColors.dangerSoft
        ),
    };

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final title = Text(
                scenario.name,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              );
              final badges = [
                _ScenarioBadge(
                  label: scenario.type.label,
                  color: chipColor,
                  backgroundColor: chipBg,
                ),
                _ScenarioBadge(
                  label: switch (scenario.status.toUpperCase()) {
                    'DRAFT' => 'Borrador',
                    'ACTIVE' => 'Activo',
                    'INACTIVE' => 'Inactivo',
                    _ => scenario.status,
                  },
                  color: SimcoreColors.textSecondary,
                  backgroundColor: SimcoreColors.surface,
                ),
              ];

              if (constraints.maxWidth < 520) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: badges),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 8),
                  ...badges
                      .expand((badge) => [badge, const SizedBox(width: 8)])
                      .take(badges.length * 2 - 1),
                ],
              );
            },
          ),
          if (scenario.description != null) ...[
            const SizedBox(height: 8),
            Text(
              scenario.description!,
              style: const TextStyle(color: SimcoreColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onActivate,
                icon: const Icon(Icons.play_arrow_rounded, size: 16),
                label: const Text('Activar'),
              ),
              if (scenario.status.toUpperCase() == 'ACTIVE')
                OutlinedButton.icon(
                  onPressed: onDeactivate,
                  icon:
                      const Icon(Icons.pause_circle_outline_rounded, size: 16),
                  label: const Text('Desactivar'),
                ),
              OutlinedButton.icon(
                onPressed: onAssign,
                icon: const Icon(Icons.group_rounded, size: 16),
                label: const Text('Asignar a grupo'),
              ),
              OutlinedButton.icon(
                onPressed: onAdvanced,
                icon: const Icon(Icons.tune_rounded, size: 16),
                label: const Text('Avanzado'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateScenarioDialog extends ConsumerStatefulWidget {
  const _CreateScenarioDialog({
    required this.courseId,
    required this.onCreated,
  });

  final int courseId;
  final VoidCallback onCreated;

  @override
  ConsumerState<_CreateScenarioDialog> createState() =>
      _CreateScenarioDialogState();
}

class _CreateScenarioDialogState extends ConsumerState<_CreateScenarioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  ScenarioType _type = ScenarioType.probable;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(scenarioFormNotifierProvider);
    final isLoading = formState is AsyncLoading;

    return AlertDialog(
      title: const Text('Nuevo escenario'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ScenarioType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: ScenarioType.values
                    .map(
                        (t) => DropdownMenuItem(value: t, child: Text(t.label)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _type = v);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: isLoading
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;

                  final notifier =
                      ref.read(scenarioFormNotifierProvider.notifier);

                  final scenario = await notifier.createScenario({
                    'courseId': widget.courseId,
                    'name': _nameCtrl.text.trim(),
                    'description': _descCtrl.text.trim(),
                    'type': _type.toApi(),
                    'variables': const <Map<String, dynamic>>[],
                  });

                  if (scenario != null && context.mounted) {
                    widget.onCreated();
                    Navigator.pop(context);
                  }
                },
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Crear'),
        ),
      ],
    );
  }
}

class _ScenarioBadge extends StatelessWidget {
  const _ScenarioBadge({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _AdvancedScenarioSheet extends ConsumerStatefulWidget {
  const _AdvancedScenarioSheet({required this.scenario});

  final Scenario scenario;

  @override
  ConsumerState<_AdvancedScenarioSheet> createState() =>
      _AdvancedScenarioSheetState();
}

class _AdvancedScenarioSheetState
    extends ConsumerState<_AdvancedScenarioSheet> {
  late bool _groupsCanSeeEachOther;
  late bool _blockR1;
  late bool _blockR2;
  late bool _blockR3;
  late bool _blockR4;
  late bool _blockR5;
  late bool _blockR6;
  final Map<String, TextEditingController> _variableControllers = {};

  @override
  void initState() {
    super.initState();
    final scenario = widget.scenario;
    _groupsCanSeeEachOther = scenario.groupsCanSeeEachOther;
    _blockR1 = scenario.blockR1;
    _blockR2 = scenario.blockR2;
    _blockR3 = scenario.blockR3;
    _blockR4 = scenario.blockR4;
    _blockR5 = scenario.blockR5;
    _blockR6 = scenario.blockR6;
    for (final variable in scenario.variables) {
      _variableControllers[variable.code] =
          TextEditingController(text: variable.value);
    }
  }

  @override
  void dispose() {
    for (final controller in _variableControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveVisibility(bool value) async {
    setState(() => _groupsCanSeeEachOther = value);
    final scenario =
        await ref.read(scenarioFormNotifierProvider.notifier).setVisibility(
              scenarioId: widget.scenario.id,
              groupsCanSeeEachOther: value,
            );
    if (!mounted) return;
    _showResult(
      scenario != null,
      'Visibilidad actualizada.',
    );
  }

  Future<void> _saveIncoherenceConfig() async {
    final scenario = await ref
        .read(scenarioFormNotifierProvider.notifier)
        .setIncoherenceConfig(
      scenarioId: widget.scenario.id,
      config: {
        'blockR1': _blockR1,
        'blockR2': _blockR2,
        'blockR3': _blockR3,
        'blockR4': _blockR4,
        'blockR5': _blockR5,
        'blockR6': _blockR6,
      },
    );
    if (!mounted) return;
    _showResult(scenario != null, 'Reglas de incoherencia actualizadas.');
  }

  Future<void> _saveVariable(ScenarioVariable variable) async {
    final raw = _variableControllers[variable.code]?.text.trim() ?? '';
    final parsed = num.tryParse(raw.replaceAll(',', '.'));
    if (parsed == null) {
      _showResult(false, 'Ingresa un valor numérico válido.');
      return;
    }

    final success =
        await ref.read(scenarioFormNotifierProvider.notifier).updateVariable(
              scenarioId: widget.scenario.id,
              code: variable.code,
              value: parsed,
            );
    if (!mounted) return;
    _showResult(success, 'Variable actualizada.');
  }

  Future<void> _deleteScenario() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar escenario'),
        content: const Text(
          'Solo se eliminará si el backend confirma que no está en uso.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                FilledButton.styleFrom(backgroundColor: SimcoreColors.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final success = await ref
        .read(scenarioFormNotifierProvider.notifier)
        .deleteScenario(widget.scenario.id);
    if (!mounted) return;
    _showResult(success, 'Escenario eliminado.');
    if (success) Navigator.pop(context);
  }

  void _showResult(bool success, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? message : 'No se pudo completar la acción.'),
        backgroundColor: success ? SimcoreColors.success : SimcoreColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(scenarioFormNotifierProvider).isLoading;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: SimcoreColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.scenario.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Configuración avanzada del escenario',
                  style: TextStyle(color: SimcoreColors.textSecondary),
                ),
                const SizedBox(height: 20),
                GlassPanel(
                  padding: const EdgeInsets.all(16),
                  child: SwitchListTile(
                    value: _groupsCanSeeEachOther,
                    onChanged: isLoading ? null : _saveVisibility,
                    title: const Text('Comparación visible entre grupos'),
                    subtitle: const Text(
                      'Permite que estudiantes vean resultados de otros grupos.',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GlassPanel(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const IconTitle(
                        icon: Icons.rule_rounded,
                        title: 'Reglas bloqueantes',
                      ),
                      const SizedBox(height: 8),
                      _RuleSwitch(
                        title: 'R1 - Mercado insuficiente',
                        value: _blockR1,
                        onChanged: (v) => setState(() => _blockR1 = v),
                      ),
                      _RuleSwitch(
                        title: 'R2 - Financiamiento excesivo',
                        value: _blockR2,
                        onChanged: (v) => setState(() => _blockR2 = v),
                      ),
                      _RuleSwitch(
                        title: 'R3 - Capacidad organizativa',
                        value: _blockR3,
                        onChanged: (v) => setState(() => _blockR3 = v),
                      ),
                      _RuleSwitch(
                        title: 'R4 - Contabilidad incompleta',
                        value: _blockR4,
                        onChanged: (v) => setState(() => _blockR4 = v),
                      ),
                      _RuleSwitch(
                        title: 'R5 - Indicadores críticos',
                        value: _blockR5,
                        onChanged: (v) => setState(() => _blockR5 = v),
                      ),
                      _RuleSwitch(
                        title: 'R6 - Coherencia global',
                        value: _blockR6,
                        onChanged: (v) => setState(() => _blockR6 = v),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: isLoading ? null : _saveIncoherenceConfig,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Guardar reglas'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassPanel(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const IconTitle(
                        icon: Icons.tune_rounded,
                        title: 'Variables',
                      ),
                      const SizedBox(height: 12),
                      if (widget.scenario.variables.isEmpty)
                        const Text(
                          'Este escenario no tiene variables configuradas.',
                          style: TextStyle(color: SimcoreColors.textSecondary),
                        )
                      else
                        ...widget.scenario.variables.map(
                          (variable) => _VariableEditor(
                            variable: variable,
                            controller: _variableControllers[variable.code]!,
                            onSave: isLoading
                                ? null
                                : () => _saveVariable(variable),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : _deleteScenario,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: SimcoreColors.danger,
                    ),
                    label: const Text(
                      'Eliminar escenario',
                      style: TextStyle(color: SimcoreColors.danger),
                    ),
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

class _RuleSwitch extends StatelessWidget {
  const _RuleSwitch({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(title),
    );
  }
}

class _VariableEditor extends StatelessWidget {
  const _VariableEditor({
    required this.variable,
    required this.controller,
    required this.onSave,
  });

  final ScenarioVariable variable;
  final TextEditingController controller;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final label = variable.displayName ?? variable.code;
    final helper = [
      if (variable.unit != null && variable.unit!.isNotEmpty) variable.unit,
      if (variable.minValue != null || variable.maxValue != null)
        '${variable.minValue?.toStringAsFixed(0) ?? '-'} - ${variable.maxValue?.toStringAsFixed(0) ?? '-'}',
      if (variable.locked) 'bloqueada',
    ].whereType<String>().join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !variable.locked,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: label,
                helperText: helper.isEmpty ? variable.description : helper,
                filled: true,
                fillColor: SimcoreColors.muted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: variable.locked ? null : onSave,
            icon: const Icon(Icons.save_outlined),
          ),
        ],
      ),
    );
  }
}

class _AssignScenarioDialog extends ConsumerStatefulWidget {
  const _AssignScenarioDialog({
    required this.scenarioId,
    required this.courseId,
  });

  final int scenarioId;
  final int courseId;

  @override
  ConsumerState<_AssignScenarioDialog> createState() =>
      _AssignScenarioDialogState();
}

class _AssignScenarioDialogState extends ConsumerState<_AssignScenarioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _groupIdController = TextEditingController();
  Map<String, dynamic>? _selectedGroup;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _groupIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(groupsByCourseProvider(widget.courseId));

    return AlertDialog(
      title: const Text('Asignar escenario a grupo'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Selecciona el grupo del curso al que quieres asignar este escenario.',
                style:
                    TextStyle(color: SimcoreColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              groupsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Text(
                  'Error al cargar grupos: $e',
                  style: const TextStyle(color: SimcoreColors.danger),
                ),
                data: (groups) {
                  if (groups.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No hay grupos creados en este curso.',
                        style: TextStyle(
                            color: SimcoreColors.warning, fontSize: 13),
                      ),
                    );
                  }

                  return Autocomplete<Map<String, dynamic>>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<Map<String, dynamic>>.empty();
                      }
                      return groups.where((g) {
                        final name = g['name']?.toString().toLowerCase() ?? '';
                        return name
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    displayStringForOption: (option) =>
                        option['name']?.toString() ?? '',
                    onSelected: (option) {
                      setState(() {
                        _selectedGroup = option;
                        _groupIdController.text = option['id'].toString();
                      });
                    },
                    fieldViewBuilder:
                        (context, textController, focusNode, onFieldSubmitted) {
                      textController.addListener(() {
                        if (textController.text.isEmpty &&
                            _selectedGroup != null) {
                          setState(() {
                            _selectedGroup = null;
                            _groupIdController.clear();
                          });
                        }
                      });

                      return TextFormField(
                        controller: textController,
                        focusNode: focusNode,
                        style: const TextStyle(
                          fontSize: 14,
                          color: SimcoreColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Nombre del grupo',
                          hintText: 'Escribe para buscar...',
                          prefixIcon: const Icon(Icons.group_outlined,
                              color: SimcoreColors.textTertiary),
                          filled: true,
                          fillColor: SimcoreColors.muted,
                          labelStyle: const TextStyle(
                              color: SimcoreColors.textSecondary),
                          hintStyle: const TextStyle(
                              color: SimcoreColors.textTertiary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: SimcoreColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: SimcoreColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: SimcoreColors.accent, width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: SimcoreColors.danger),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: SimcoreColors.danger, width: 1.5),
                          ),
                          errorStyle:
                              const TextStyle(color: SimcoreColors.danger),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Selecciona un grupo';
                          }
                          if (_selectedGroup == null ||
                              _selectedGroup!['name'] != value) {
                            return 'Selecciona una sugerencia de la lista';
                          }
                          return null;
                        },
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 8,
                          color: SimcoreColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: MediaQuery.sizeOf(context)
                                .width
                                .clamp(240.0, 320.0),
                            constraints: const BoxConstraints(maxHeight: 180),
                            decoration: BoxDecoration(
                              border: Border.all(color: SimcoreColors.border),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final option = options.elementAt(index);
                                return InkWell(
                                  onTap: () => onSelected(option),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.business_rounded,
                                            color: SimcoreColors.accent,
                                            size: 18),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            option['name']?.toString() ?? '',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: SimcoreColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submitAssign,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Asignar'),
        ),
      ],
    );
  }

  Future<void> _submitAssign() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final groupId = int.parse(_groupIdController.text.trim());
    final success =
        await ref.read(scenarioFormNotifierProvider.notifier).assignToGroup(
              scenarioId: widget.scenarioId,
              groupId: groupId,
            );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ref.invalidate(activeScenarioProvider);
      ref.invalidate(scenariosByCourseProvider);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Escenario ${widget.scenarioId} asignado correctamente al grupo ${_selectedGroup?['name'] ?? groupId}.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo asignar el escenario. Revisa si pertenece al curso del grupo.',
          ),
        ),
      );
    }
  }
}
