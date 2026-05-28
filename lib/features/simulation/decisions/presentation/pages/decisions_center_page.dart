import 'dart:async';
import 'dart:convert';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/config/app_config.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/models/decision_model.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/repositories/decision_impact_tree.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/repositories/decision_providers.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';
import 'package:simcore_frontend/features/simulation/module_progress/presentation/providers/module_progress_providers.dart' as module_actions;
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_providers.dart' as global_providers;

class DecisionsPage extends ConsumerStatefulWidget {
  const DecisionsPage({super.key});

  @override
  ConsumerState<DecisionsPage> createState() => _DecisionsPageState();
}

class _DecisionsPageState extends ConsumerState<DecisionsPage> {
  int currentTab = 0;
  bool isSubmitted = false;
  double signProgress = 0;
  Timer? _signTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final companyId = ref.read(currentCompanyIdProvider).toString();
      if (companyId.isNotEmpty) {
        ref.read(module_actions.moduleProgressProvider.notifier).start(
              companyId,
              SimModule.decisions.toApi(),
            );
      }
    });
  }

  @override
  void dispose() {
    _signTimer?.cancel();
    super.dispose();
  }

  void _startSigning() {
    if (isSubmitted) {
      return;
    }
    _signTimer?.cancel();
    _signTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      setState(() {
        signProgress += 2;
        if (signProgress >= 100) {
          signProgress = 100;
          isSubmitted = true;
          final companyId = ref.read(currentCompanyIdProvider).toString();
          if (companyId.isNotEmpty) {
            ref.read(module_actions.moduleProgressProvider.notifier).complete(
                  companyId,
                  SimModule.decisions.toApi(),
                );
            ref.invalidate(global_providers.moduleProgressProvider);
          }
          timer.cancel();
        }
      });
    });
  }

  void _stopSigning() {
    _signTimer?.cancel();
    if (!isSubmitted) {
      setState(() => signProgress = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = ref.watch(appConfigProvider);

    final tabs = const [
      ('Decisiones Registradas', Icons.history_edu_rounded),
      ('Registrar Nueva Decisión', Icons.add_circle_outline_rounded),
      ('Firma del Ciclo', Icons.fingerprint_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageIntro(
          title: 'Centro de Decisiones',
          subtitle: 'Consulta, registra y finaliza las decisiones estratégicas de tu compañía para el ciclo actual.',
          trailing: GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hub_rounded, color: SimcoreColors.success),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Servidor de Simulacion',
                        style: TextStyle(
                            fontSize: 11, color: SimcoreColors.textTertiary)),
                    Text(
                        '${appConfig.environment.name.toUpperCase()} - ${appConfig.simUrl}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: SimcoreColors.success)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        LayoutBuilder(builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 520;
          final tabItems = List.generate(tabs.length, (index) {
            final active = index == currentTab;
            final item = InkWell(
              onTap:
                  isSubmitted ? null : () => setState(() => currentTab = index),
              child: isCompact
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: active ? SimcoreColors.accentSoft : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: SimcoreColors.border),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: active
                                    ? SimcoreColors.accent
                                    : SimcoreColors.surface,
                            child: Icon(
                              tabs[index].$2,
                              size: 18,
                              color: active
                                  ? Colors.white
                                  : SimcoreColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tabs[index].$1,
                              softWrap: true,
                              style: TextStyle(
                                fontWeight:
                                    active ? FontWeight.w700 : FontWeight.w500,
                                color: active
                                    ? SimcoreColors.textPrimary
                                    : SimcoreColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: active
                                  ? SimcoreColors.accent
                                  : SimcoreColors.surface,
                          child: Icon(
                            tabs[index].$2,
                            color: active
                                ? Colors.white
                                : SimcoreColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          tabs[index].$1,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: TextStyle(
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500,
                            color: active
                                ? SimcoreColors.textPrimary
                                : SimcoreColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
            );

            return isCompact ? item : Expanded(child: item);
          });

          if (isCompact) {
            return Column(
              children: tabItems
                  .expand((child) => [child, const SizedBox(height: 8)])
                  .take(tabItems.length * 2 - 1)
                  .toList(growable: false),
            );
          }

          return Row(children: tabItems);
        }),
        const SizedBox(height: 24),
        if (currentTab == 0)
          const _DecisionsListTab(),
        if (currentTab == 1)
          const _NewDecisionTab(),
        if (currentTab == 2)
          _SignTab(
            signProgress: signProgress,
            isSubmitted: isSubmitted,
            onStart: _startSigning,
            onStop: _stopSigning,
          ),
      ],
    );
  }
}

class _DecisionsListTab extends ConsumerWidget {
  const _DecisionsListTab();

  void _showDecisionDetails(BuildContext context, DecisionModel decision) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalle de Decisión: ${decision.decisionType}'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Módulo: ${decision.module}'),
              const SizedBox(height: 8),
              Text('Justificación: ${decision.justification}'),
              const Divider(height: 24),
              const Text('Impacto en otros módulos:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DecisionImpactTree(decisionId: decision.id),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisionsAsync = ref.watch(companyDecisionsProvider);

    return decisionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (decisions) {
        if (decisions.isEmpty) {
          return const Center(child: Text('No hay decisiones registradas para esta compañía.'));
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: decisions.length,
          itemBuilder: (context, index) {
            final decision = decisions[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.receipt_long_rounded),
                title: Text('${decision.decisionType} en ${decision.module}'),
                subtitle: Text(decision.justification, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                onTap: () => _showDecisionDetails(context, decision),
              ),
            );
          },
        );
      },
    );
  }
}

class _NewDecisionTab extends ConsumerStatefulWidget {
  const _NewDecisionTab();

  @override
  ConsumerState<_NewDecisionTab> createState() => _NewDecisionTabState();
}

class _NewDecisionTabState extends ConsumerState<_NewDecisionTab> {
  final _formKey = GlobalKey<FormState>();
  final _decisionTypeController = TextEditingController();
  final _payloadController = TextEditingController();
  final _justificationController = TextEditingController();
  SimModule? _selectedModule;

  @override
  void dispose() {
    _decisionTypeController.dispose();
    _payloadController.dispose();
    _justificationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final companyId = ref.read(currentCompanyIdProvider).toString();
      final newDecision = DecisionModel(
        id: '', // El backend asignará el ID
        companyId: companyId,
        module: _selectedModule!.toApi(),
        decisionType: _decisionTypeController.text,
        payload: jsonDecode(_payloadController.text),
        justification: _justificationController.text,
      );

      final success = await ref.read(decisionNotifierProvider.notifier).createDecision(newDecision);

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Decisión registrada con éxito'), backgroundColor: SimcoreColors.success),
        );
        _formKey.currentState!.reset();
        setState(() => _selectedModule = null);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar la decisión'), backgroundColor: SimcoreColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final decisionState = ref.watch(decisionNotifierProvider);

    return GlassPanel(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Registrar Nueva Decisión', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            DropdownButtonFormField<SimModule>(
              value: _selectedModule,
              hint: const Text('Seleccionar Módulo'),
              items: SimModule.values.map((module) {
                return DropdownMenuItem(value: module, child: Text(module.label));
              }).toList(),
              onChanged: (value) => setState(() => _selectedModule = value),
              validator: (value) => value == null ? 'Por favor, seleccione un módulo' : null,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _decisionTypeController,
              decoration: const InputDecoration(labelText: 'Tipo de Decisión (ej. SET_PRICE)', border: OutlineInputBorder()),
              validator: (value) => value == null || value.isEmpty ? 'Este campo es requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _payloadController,
              decoration: const InputDecoration(labelText: 'Payload (en formato JSON)', border: OutlineInputBorder()),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Este campo es requerido';
                try {
                  jsonDecode(value);
                  return null;
                } catch (e) {
                  return 'El formato JSON no es válido';
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _justificationController,
              decoration: const InputDecoration(labelText: 'Justificación de la decisión', border: OutlineInputBorder()),
              maxLines: 3,
              validator: (value) => value == null || value.isEmpty ? 'Este campo es requerido' : null,
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: decisionState.isLoading ? null : _submitForm,
                icon: decisionState.isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
                label: const Text('Guardar Decisión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignTab extends StatelessWidget {
  const _SignTab({
    required this.signProgress,
    required this.isSubmitted,
    required this.onStart,
    required this.onStop,
  });

  final double signProgress;
  final bool isSubmitted;
  final VoidCallback onStart;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: GlassPanel(
          padding: const EdgeInsets.all(36),
          child: Column(
            children: [
              Text(
                isSubmitted
                    ? 'Estrategia enviada'
                    : 'Mantener presionado para firmar',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                isSubmitted
                    ? 'Las decisiones quedaron bloqueadas y listas para ser procesadas por el motor de simulacion.'
                    : 'La firma ejecutiva sella la estrategia consolidada y bloquea cambios en todos los modulos.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onLongPressStart: (_) => onStart(),
                onLongPressEnd: (_) => onStop(),
                child: Container(
                  width: double.infinity,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: SimcoreColors.textPrimary,
                  ),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: signProgress / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: isSubmitted
                                ? SimcoreColors.success
                                : SimcoreColors.accent,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          isSubmitted
                              ? 'Firmado y enviado'
                              : 'Mantener para firmar',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isSubmitted
                    ? '100% completado'
                    : '${signProgress.toInt()}% de firma',
                style: const TextStyle(color: SimcoreColors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
