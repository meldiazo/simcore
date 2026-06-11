import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/features/simulation/scenario/domain/entities/scenario.dart';
import 'package:simcore_frontend/features/simulation/scenario/presentation/providers/scenario_providers.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

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
  final ctrl = TextEditingController(
    text: currentContext?.groupId.toString() ?? '',
  );

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Asignar escenario a grupo'),
      content: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'ID del grupo',
          helperText: 'Usa el grupo del curso que quieres evaluar.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            final groupId = int.tryParse(ctrl.text.trim());

            if (groupId == null || groupId <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ingresa un ID de grupo válido.'),
                ),
              );
              return;
            }

            final success = await ref
                .read(scenarioFormNotifierProvider.notifier)
                .assignToGroup(
                  scenarioId: scenarioId,
                  groupId: groupId,
                );

            if (!context.mounted || !dialogContext.mounted) return;

            if (success) {
              ref.invalidate(activeScenarioProvider);
              ref.invalidate(scenariosByCourseProvider);

              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Escenario $scenarioId asignado correctamente al grupo $groupId.',
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
          },
          child: const Text('Asignar'),
        ),
      ],
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
                  scenario.status,
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
