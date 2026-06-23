import 'dart:async';
import 'dart:convert';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/models/decision_model.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/repositories/decision_impact_tree.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/repositories/decision_providers.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';
import 'package:simcore_frontend/core/error/error_utils.dart';

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
      if (!mounted) {
        timer.cancel();
        return;
      }

      final nextProgress = signProgress + 2;
      final shouldSubmit = nextProgress >= 100;

      setState(() {
        signProgress = shouldSubmit ? 100 : nextProgress;
        isSubmitted = shouldSubmit;
      });

      if (shouldSubmit) {
        timer.cancel();
        showSimcoreSuccessDialog(
          context: context,
          title: '¡Estrategia Firmada!',
          message: 'La estrategia para el ciclo actual ha sido firmada y enviada correctamente.',
        );
      }
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
    final tabs = const [
      ('Decisiones Registradas', Icons.history_edu_rounded),
      ('Registrar Nueva Decisión', Icons.add_circle_outline_rounded),
      ('Firma del Ciclo', Icons.fingerprint_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageIntro(
          title: 'Centro de Decisiones',
          subtitle: 'Consulta, registra y finaliza las decisiones estratégicas de tu compañía para el ciclo actual.',
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
      error: (err, stack) => Center(child: Text('Error: ${toUserFriendlyError(err)}')),
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

class ParameterRow {
  final TextEditingController keyController;
  final TextEditingController valueController;
  ParameterRow({required this.keyController, required this.valueController});
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

  bool _isJsonMode = false;
  final List<ParameterRow> _parameterRows = [];

  @override
  void initState() {
    super.initState();
    _parameterRows.add(ParameterRow(
      keyController: TextEditingController(),
      valueController: TextEditingController(),
    ));
  }

  @override
  void dispose() {
    _decisionTypeController.dispose();
    _payloadController.dispose();
    _justificationController.dispose();
    for (final row in _parameterRows) {
      row.keyController.dispose();
      row.valueController.dispose();
    }
    super.dispose();
  }

  dynamic _parseValue(String value) {
    final trimmed = value.trim();
    if (trimmed.toLowerCase() == 'true') return true;
    if (trimmed.toLowerCase() == 'false') return false;
    final intVal = int.tryParse(trimmed);
    if (intVal != null) return intVal;
    final doubleVal = double.tryParse(trimmed);
    if (doubleVal != null) return doubleVal;
    return trimmed;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final companyId = ref.read(currentCompanyIdProvider).toString();

      Map<String, dynamic> finalPayload = {};
      if (_isJsonMode) {
        try {
          finalPayload = jsonDecode(_payloadController.text);
        } catch (e) {
          return;
        }
      } else {
        for (final row in _parameterRows) {
          final key = row.keyController.text.trim();
          final valStr = row.valueController.text.trim();
          if (key.isNotEmpty) {
            finalPayload[key] = _parseValue(valStr);
          }
        }
      }

      final newDecision = DecisionModel(
        id: '', // El backend asignará el ID
        companyId: companyId,
        module: _selectedModule!.toApi(),
        decisionType: _decisionTypeController.text,
        payload: finalPayload,
        justification: _justificationController.text,
      );

      final success = await ref.read(decisionNotifierProvider.notifier).createDecision(newDecision);

      if (mounted) {
        if (success) {
          showSimcoreSuccessDialog(
            context: context,
            title: '¡Decisión Registrada!',
            message: 'La decisión ha sido registrada y guardada exitosamente.',
          );
          _formKey.currentState!.reset();
          setState(() {
            _selectedModule = null;
            for (final r in _parameterRows) {
              r.keyController.dispose();
              r.valueController.dispose();
            }
            _parameterRows.clear();
            _parameterRows.add(ParameterRow(
              keyController: TextEditingController(),
              valueController: TextEditingController(),
            ));
            _payloadController.clear();
          });
        } else {
          final decisionState = ref.read(decisionNotifierProvider);
          final errorMsg = toUserFriendlyError(decisionState.error);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error al registrar la decisión'),
              content: Text(errorMsg),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  Widget _buildKeyValueEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Parámetros de la Decisión',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _parameterRows.add(ParameterRow(
                    keyController: TextEditingController(),
                    valueController: TextEditingController(),
                  ));
                });
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Añadir Parámetro'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_parameterRows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                'No se han agregado parámetros. Se enviará un payload vacío.',
                style: TextStyle(
                  color: SimcoreColors.textSecondary.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _parameterRows.length,
            itemBuilder: (context, index) {
              final row = _parameterRows[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: row.keyController,
                        decoration: const InputDecoration(
                          labelText: 'Clave (ej: price)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        controller: row.valueController,
                        decoration: const InputDecoration(
                          labelText: 'Valor (ej: 250)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: SimcoreColors.danger),
                      onPressed: () {
                        setState(() {
                          row.keyController.dispose();
                          row.valueController.dispose();
                          _parameterRows.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
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
              initialValue: _selectedModule,
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Formato del Payload', style: TextStyle(fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    const Text('Formulario Clave-Valor', style: TextStyle(fontSize: 13)),
                    Switch(
                      value: _isJsonMode,
                      onChanged: (val) {
                        setState(() {
                          _isJsonMode = val;
                          if (_isJsonMode) {
                            final Map<String, dynamic> currentMap = {};
                            for (final row in _parameterRows) {
                              final key = row.keyController.text.trim();
                              final valStr = row.valueController.text.trim();
                              if (key.isNotEmpty) {
                                currentMap[key] = _parseValue(valStr);
                              }
                            }
                            _payloadController.text = const JsonEncoder.withIndent('  ').convert(currentMap);
                          } else {
                            try {
                              final decoded = jsonDecode(_payloadController.text);
                              if (decoded is Map<String, dynamic>) {
                                for (final r in _parameterRows) {
                                  r.keyController.dispose();
                                  r.valueController.dispose();
                                }
                                _parameterRows.clear();
                                decoded.forEach((k, v) {
                                  _parameterRows.add(ParameterRow(
                                    keyController: TextEditingController(text: k),
                                    valueController: TextEditingController(text: v.toString()),
                                  ));
                                });
                              }
                            } catch (_) {}
                          }
                        });
                      },
                    ),
                    const Text('JSON Avanzado', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isJsonMode)
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
              )
            else
              _buildKeyValueEditor(),
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

class _SignTab extends StatefulWidget {
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
  State<_SignTab> createState() => _SignTabState();
}

class _SignTabState extends State<_SignTab> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.isSubmitted;
    final progressVal = widget.signProgress / 100.0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: GlassPanel(
          padding: const EdgeInsets.all(36),
          child: Column(
            children: [
              Text(
                isCompleted
                    ? 'Estrategia Firmada'
                    : 'Firma Biométrica de Estrategia',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                isCompleted
                    ? 'La estrategia quedó firmada en esta sesión y lista para su revisión académica.'
                    : 'Mantén presionado el sensor de huella dactilar para firmar y finalizar la estrategia del ciclo.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: SimcoreColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onLongPressDown: (_) {
                  if (!isCompleted) {
                    setState(() => _isPressed = true);
                  }
                },
                onLongPressStart: (_) {
                  if (!isCompleted) {
                    widget.onStart();
                  }
                },
                onLongPressEnd: (_) {
                  setState(() => _isPressed = false);
                  widget.onStop();
                },
                onLongPressUp: () {
                  setState(() => _isPressed = false);
                },
                child: Column(
                  children: [
                    AnimatedScale(
                      scale: _isPressed ? 1.08 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOutBack,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? SimcoreColors.successSoft.withValues(alpha: 0.2)
                              : (_isPressed
                                  ? SimcoreColors.accentSoft.withValues(alpha: 0.3)
                                  : SimcoreColors.glass),
                          border: Border.all(
                            color: isCompleted
                                ? SimcoreColors.success
                                : (_isPressed ? SimcoreColors.accent : SimcoreColors.border),
                            width: 2,
                          ),
                          boxShadow: [
                            if (_isPressed && !isCompleted)
                              BoxShadow(
                                color: SimcoreColors.accent.withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            if (isCompleted)
                              BoxShadow(
                                color: SimcoreColors.success.withValues(alpha: 0.3),
                                blurRadius: 15,
                                spreadRadius: 1,
                              ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: progressVal,
                                strokeWidth: 6,
                                backgroundColor: SimcoreColors.border.withValues(alpha: 0.5),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isCompleted ? SimcoreColors.success : SimcoreColors.accent,
                                ),
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(scale: animation, child: child);
                              },
                              child: isCompleted
                                  ? const Icon(
                                      Icons.check_circle_rounded,
                                      key: ValueKey('check'),
                                      size: 64,
                                      color: SimcoreColors.success,
                                    )
                                  : Icon(
                                      Icons.fingerprint_rounded,
                                      key: const ValueKey('fingerprint'),
                                      size: 64,
                                      color: _isPressed
                                          ? SimcoreColors.accent
                                          : SimcoreColors.textTertiary,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: isCompleted
                            ? SimcoreColors.success
                            : (_isPressed ? SimcoreColors.accent : SimcoreColors.textTertiary),
                      ),
                      child: Text(
                        isCompleted
                            ? 'Firmado y enviado'
                            : (_isPressed
                                ? 'Escaneando huella... ${widget.signProgress.toInt()}%'
                                : 'Mantén presionado para firmar'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

