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
    final scenariosAsync = ref.watch(scenariosByCourseProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageIntro(
          title: 'Gestión de Escenarios',
          subtitle: 'Crea, activa y asigna escenarios a los grupos del curso.',
          trailing: FilledButton.icon(
            onPressed: () => _showCreateDialog(context, ref),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nuevo escenario'),
          ),
        ),
        const SizedBox(height: 24),
        scenariosAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => GlassPanel(
            child: Text('Error: $e', style: const TextStyle(color: SimcoreColors.danger)),
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
                          onAssign: () => _showAssignDialog(context, ref, s.id),
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _CreateScenarioDialog(
        onCreated: () => ref.invalidate(scenariosByCourseProvider),
      ),
    );
  }

  void _showAssignDialog(BuildContext context, WidgetRef ref, int scenarioId) {
    final currentContext = ref.read(simulationContextNotifierProvider).context;
    final courseId = currentContext?.courseId;

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
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({
    required this.scenario,
    required this.onActivate,
    required this.onAssign,
  });

  final Scenario scenario;
  final VoidCallback onActivate;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    final (chipColor, chipBg) = switch (scenario.type) {
      ScenarioType.probable => (SimcoreColors.accent, SimcoreColors.accentSoft),
      ScenarioType.optimistic => (SimcoreColors.success, SimcoreColors.successSoft),
      ScenarioType.pessimistic => (SimcoreColors.danger, SimcoreColors.dangerSoft),
    };

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  scenario.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  scenario.type.label,
                  style: TextStyle(color: chipColor, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: SimcoreColors.surface,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  switch (scenario.status.toUpperCase()) {
                    'DRAFT' => 'Borrador',
                    'ACTIVE' => 'Activo',
                    'INACTIVE' => 'Inactivo',
                    _ => scenario.status,
                  },
                  style: const TextStyle(
                    fontSize: 12,
                    color: SimcoreColors.textSecondary,
                  ),
                ),
              ),
            ],
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
            children: [
              OutlinedButton.icon(
                onPressed: onActivate,
                icon: const Icon(Icons.play_arrow_rounded, size: 16),
                label: const Text('Activar'),
              ),
              OutlinedButton.icon(
                onPressed: onAssign,
                icon: const Icon(Icons.group_rounded, size: 16),
                label: const Text('Asignar a grupo'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateScenarioDialog extends ConsumerStatefulWidget {
  const _CreateScenarioDialog({required this.onCreated});

  final VoidCallback onCreated;

  @override
  ConsumerState<_CreateScenarioDialog> createState() => _CreateScenarioDialogState();
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
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
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
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _type = v);
              },
            ),
          ],
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

        final simulationContext =
            ref.read(simulationContextNotifierProvider).context;

        final courseId = simulationContext?.courseId;

        if (courseId == null || courseId <= 0) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'No se pudo determinar el curso actual para crear el escenario.',
                ),
              ),
            );
          }
          return;
        }

        final notifier = ref.read(scenarioFormNotifierProvider.notifier);

        final scenario = await notifier.createScenario({
          'courseId': courseId,
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

class _AssignScenarioDialog extends ConsumerStatefulWidget {
  const _AssignScenarioDialog({
    required this.scenarioId,
    required this.courseId,
  });

  final int scenarioId;
  final int courseId;

  @override
  ConsumerState<_AssignScenarioDialog> createState() => _AssignScenarioDialogState();
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
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Selecciona el grupo del curso al que quieres asignar este escenario.',
                style: TextStyle(color: SimcoreColors.textSecondary, fontSize: 13),
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
                        style: TextStyle(color: SimcoreColors.warning, fontSize: 13),
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
                        return name.contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    displayStringForOption: (option) => option['name']?.toString() ?? '',
                    onSelected: (option) {
                      setState(() {
                        _selectedGroup = option;
                        _groupIdController.text = option['id'].toString();
                      });
                    },
                    fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                      textController.addListener(() {
                        if (textController.text.isEmpty && _selectedGroup != null) {
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
                          prefixIcon: const Icon(Icons.group_outlined, color: SimcoreColors.textTertiary),
                          filled: true,
                          fillColor: SimcoreColors.muted,
                          labelStyle: const TextStyle(color: SimcoreColors.textSecondary),
                          hintStyle: const TextStyle(color: SimcoreColors.textTertiary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: SimcoreColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: SimcoreColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: SimcoreColors.accent, width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: SimcoreColors.danger),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: SimcoreColors.danger, width: 1.5),
                          ),
                          errorStyle: const TextStyle(color: SimcoreColors.danger),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Selecciona un grupo';
                          }
                          if (_selectedGroup == null || _selectedGroup!['name'] != value) {
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
                            width: 320,
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
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.business_rounded, color: SimcoreColors.accent, size: 18),
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
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
    final success = await ref.read(scenarioFormNotifierProvider.notifier).assignToGroup(
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
