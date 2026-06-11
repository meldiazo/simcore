import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/router/app_router.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/validation/form_validators.dart';
import 'package:simcore_frontend/features/academic/presentation/providers/academic_providers.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/form_error_summary.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/features/simulation/company/presentation/providers/company_providers.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

class GroupManagerPage extends ConsumerStatefulWidget {
  const GroupManagerPage({super.key});

  @override
  ConsumerState<GroupManagerPage> createState() => _GroupManagerPageState();
}

class _GroupManagerPageState extends ConsumerState<GroupManagerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final List<int> _pendingMemberIds = [];
  Map<String, String> _fieldErrors = {};
  int? _selectedCourseId;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _fieldErrors = {});

    final contextState = ref.read(simulationContextNotifierProvider);
    final activeCourseId = contextState.context?.courseId;

    final targetCourseId = activeCourseId ?? _selectedCourseId;
    if (targetCourseId == null) {
      setState(() => _fieldErrors = {'error': 'No se pudo determinar el ID del curso.'});
      return;
    }

    try {
      await ref.read(groupNotifierProvider.notifier).createGroup(
            name: _nameCtrl.text.trim(),
            courseId: targetCourseId,
          );
    } catch (e) {
      setState(() => _fieldErrors = {'error': e.toString()});
    }
  }

  void _addMemberId(int id) {
    if (!_pendingMemberIds.contains(id)) {
      setState(() {
        _pendingMemberIds.add(id);
      });
    }
  }

  Future<void> _addMembers(int groupId) async {
    if (_pendingMemberIds.isEmpty) return;
    await ref.read(groupNotifierProvider.notifier).addMembers(
          groupId: groupId,
          memberIds: List<int>.from(_pendingMemberIds),
        );
    setState(() => _pendingMemberIds.clear());
  }

  Future<void> _linkCompany(int groupId, int companyId) async {
    await ref.read(groupNotifierProvider.notifier).linkCompany(
          groupId: groupId,
          companyId: companyId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupNotifierProvider);
    final contextState = ref.watch(simulationContextNotifierProvider);
    final activeCourseId = contextState.context?.courseId;

    final coursesAsync = activeCourseId == null ? ref.watch(coursesProvider) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageIntro(
          title: 'Gestión de Grupos',
          subtitle: 'Crear y administrar grupos dentro de un curso.',
        ),
        const SizedBox(height: 24),
        GlassPanel(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Crear Grupo',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 16),
                FormErrorSummary(errors: _fieldErrors),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre del grupo'),
                  validator: (v) =>
                      FormValidators.required(v, fieldName: 'Nombre'),
                ),
                if (activeCourseId == null && coursesAsync != null) ...[
                  const SizedBox(height: 12),
                  coursesAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, _) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('Error al cargar cursos: $err',
                          style: const TextStyle(color: SimcoreColors.danger)),
                    ),
                    data: (courses) {
                      if (courses.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Primero debes crear un curso en la pestaña de Gestión de Cursos.',
                            style: TextStyle(color: SimcoreColors.warning),
                          ),
                        );
                      }
                      return DropdownButtonFormField<int>(
                        value: _selectedCourseId,
                        decoration: const InputDecoration(labelText: 'Selecciona el curso'),
                        items: courses.map((c) {
                          final id = c['id'] as int? ?? 0;
                          final name = (c['name'] ?? c['title'] ?? '').toString();
                          final code = (c['code'] ?? '').toString();
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text('$name ($code)'),
                          );
                        }).toList(),
                        onChanged: (v) {
                          setState(() {
                            _selectedCourseId = v;
                          });
                        },
                        validator: (v) => v == null ? 'Selecciona un curso' : null,
                      );
                    },
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: groupState.isLoading ? null : _create,
                  icon: groupState.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.add_rounded),
                  label: const Text('Crear Grupo'),
                ),
              ],
            ),
          ),
        ),
        if (groupState.hasValue && groupState.value != null) ...[
          const SizedBox(height: 20),
          _GroupResultPanel(
            data: groupState.value!,
            pendingMembers: _pendingMemberIds,
            onAddMember: _addMemberId,
            onRemoveMember: (id) =>
                setState(() => _pendingMemberIds.remove(id)),
            onSendMembers: _addMembers,
            onLinkCompany: _linkCompany,
          ),
        ],
        if (groupState.hasError)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              groupState.error.toString(),
              style: const TextStyle(color: SimcoreColors.danger),
            ),
          ),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _GroupResultPanel extends ConsumerStatefulWidget {
  const _GroupResultPanel({
    required this.data,
    required this.pendingMembers,
    required this.onAddMember,
    required this.onRemoveMember,
    required this.onSendMembers,
    required this.onLinkCompany,
  });

  final Map<String, dynamic> data;
  final List<int> pendingMembers;
  final void Function(int id) onAddMember;
  final void Function(int id) onRemoveMember;
  final void Function(int groupId) onSendMembers;
  final void Function(int groupId, int companyId) onLinkCompany;

  @override
  ConsumerState<_GroupResultPanel> createState() => _GroupResultPanelState();
}

class _GroupResultPanelState extends ConsumerState<_GroupResultPanel> {
  int? _selectedMemberId;
  int? _selectedCompanyId;

  @override
  Widget build(BuildContext context) {
    final groupId = widget.data['id'] as int? ?? 0;
    final courseId = (widget.data['courseId'] as num?)?.toInt() ?? 0;

    final usersAsync = ref.watch(usersProvider);
    final companiesAsync = ref.watch(companiesByCourseProvider(courseId));

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: SimcoreColors.success),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Grupo creado — ID: $groupId',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Comparte este ID con los estudiantes del grupo.',
            style: TextStyle(color: SimcoreColors.textSecondary),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: groupId <= 0
                ? null
                : () {
                    Navigator.of(context).pushNamed(
                      AppRouter.companyForm,
                      arguments: {'groupId': groupId},
                    );
                  },
            icon: const Icon(Icons.business_rounded),
            label: const Text('Crear empresa para este grupo'),
          ),
          const Divider(height: 24),

          // Agregar miembros
          const Text('Agregar Miembros',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          usersAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('Error al cargar usuarios: $err',
                  style: const TextStyle(color: SimcoreColors.danger)),
            ),
            data: (users) {
              final students = users.where((u) {
                final roles = (u['roles'] as List?)
                    ?.map((r) => r.toString().toUpperCase().replaceAll('ROLE_', ''))
                    .toList() ?? [];
                return roles.contains('ESTUDIANTE');
              }).toList();

              if (students.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('No hay estudiantes disponibles.',
                      style: TextStyle(color: SimcoreColors.warning)),
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedMemberId,
                      decoration: const InputDecoration(
                          labelText: 'Selecciona Estudiante', isDense: true),
                      items: students.map((s) {
                        final id = s['id'] as int? ?? 0;
                        final name = '${s['firstName'] ?? ''} ${s['lastName'] ?? ''}'.trim();
                        final username = s['username'] ?? '';
                        final displayName = name.isNotEmpty ? '$name ($username)' : username;
                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(displayName),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedMemberId = v;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _selectedMemberId == null
                        ? null
                        : () {
                            widget.onAddMember(_selectedMemberId!);
                            setState(() {
                              _selectedMemberId = null;
                            });
                          },
                    icon: const Icon(Icons.person_add_rounded),
                  ),
                ],
              );
            },
          ),
          if (widget.pendingMembers.isNotEmpty) ...[
            const SizedBox(height: 8),
            usersAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (users) {
                final nameMap = {
                  for (final u in users)
                    u['id'] as int: () {
                      final name = '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim();
                      final username = u['username'] ?? '';
                      return name.isNotEmpty ? '$name ($username)' : username;
                    }()
                };

                return Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.pendingMembers.map((m) {
                    final label = nameMap[m] ?? '$m';
                    return Chip(
                      label: Text(label),
                      deleteIcon: const Icon(Icons.close_rounded, size: 14),
                      onDeleted: () => widget.onRemoveMember(m),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => widget.onSendMembers(groupId),
              icon: const Icon(Icons.group_add_rounded),
              label:
                  Text('Agregar ${widget.pendingMembers.length} miembro(s)'),
            ),
          ],

          const Divider(height: 24),

          // Vincular empresa existente
          const Text(
            'Vincular empresa existente',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          companiesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('Error al cargar empresas: $err',
                  style: const TextStyle(color: SimcoreColors.danger)),
            ),
            data: (companies) {
              if (companies.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('No hay empresas disponibles en este curso.',
                      style: TextStyle(color: SimcoreColors.warning)),
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedCompanyId,
                      decoration: const InputDecoration(
                          labelText: 'Selecciona Empresa', isDense: true),
                      items: companies.map((c) {
                        return DropdownMenuItem<int>(
                          value: c.id,
                          child: Text('${c.name} (ID: ${c.id})'),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedCompanyId = v;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _selectedCompanyId == null
                        ? null
                        : () => widget.onLinkCompany(groupId, _selectedCompanyId!),
                    child: const Text('Vincular'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
