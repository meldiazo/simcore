import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/router/app_router.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/validation/form_validators.dart';
import 'package:simcore_frontend/features/academic/presentation/providers/academic_providers.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/form_error_summary.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/core/error/error_utils.dart';

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
      setState(() =>
          _fieldErrors = {'error': 'No se pudo determinar el ID del curso.'});
      return;
    }

    await ref.read(groupNotifierProvider.notifier).createGroup(
          name: _nameCtrl.text.trim(),
          courseId: targetCourseId,
        );
    if (!mounted) return;

    final groupState = ref.read(groupNotifierProvider);
    if (groupState.hasError) {
      setState(() {
        _fieldErrors = {'error': toUserFriendlyError(groupState.error)};
      });
    } else {
      ref.invalidate(allGroupsProvider);
      showSimcoreSuccessDialog(
        context: context,
        title: '¡Grupo Creado!',
        message: 'El grupo ${_nameCtrl.text.trim()} ha sido registrado correctamente.',
      );
      _nameCtrl.clear();
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
    if (!mounted) return;

    final groupState = ref.read(groupNotifierProvider);
    if (groupState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(toUserFriendlyError(groupState.error)),
          backgroundColor: SimcoreColors.danger,
        ),
      );
    } else {
      ref.invalidate(allGroupsProvider);
      showSimcoreSuccessDialog(
        context: context,
        title: '¡Miembros Agregados!',
        message: 'Los estudiantes seleccionados han sido agregados al grupo correctamente.',
      );
      setState(() => _pendingMemberIds.clear());
    }
  }

  Future<void> _linkCompany(int groupId, int companyId) async {
    await ref.read(groupNotifierProvider.notifier).linkCompany(
          groupId: groupId,
          companyId: companyId,
        );
    if (!mounted) return;

    final groupState = ref.read(groupNotifierProvider);
    if (groupState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(toUserFriendlyError(groupState.error)),
          backgroundColor: SimcoreColors.danger,
        ),
      );
    } else {
      ref.invalidate(allGroupsProvider);
      showSimcoreSuccessDialog(
        context: context,
        title: '¡Empresa Vinculada!',
        message: 'La empresa ha sido vinculada al grupo correctamente.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupNotifierProvider);
    final contextState = ref.watch(simulationContextNotifierProvider);
    final activeCourseId = contextState.context?.courseId;
    final usersAsync = ref.watch(usersProvider);

    final coursesAsync =
        activeCourseId == null ? ref.watch(coursesProvider) : null;
    final groupsAsync = ref.watch(allGroupsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageIntro(
          title: 'Gestión de Grupos',
          subtitle: 'Crea y administra grupos de alumnos y vincúlalos con empresas.',
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
                  decoration:
                      const InputDecoration(labelText: 'Nombre del grupo'),
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
                      child: Text('Error al cargar cursos: ${toUserFriendlyError(err)}',
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
                        initialValue: _selectedCourseId,
                        decoration: const InputDecoration(
                            labelText: 'Selecciona el curso'),
                        items: courses.map((c) {
                          final id = c['id'] as int? ?? 0;
                          final name =
                              (c['name'] ?? c['title'] ?? '').toString();
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
                        validator: (v) =>
                            v == null ? 'Selecciona un curso' : null,
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
        if (groupState is AsyncData && groupState.value != null) ...[
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
        const SizedBox(height: 32),
        const Text(
          'Grupos Registrados',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        groupsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => GlassPanel(
            child: Center(
              child: Text(
                'Error al cargar grupos: ${toUserFriendlyError(err)}',
                style: const TextStyle(color: SimcoreColors.danger),
              ),
            ),
          ),
          data: (groups) {
            if (groups.isEmpty) {
              return const GlassPanel(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No hay grupos registrados en el sistema.',
                      style: TextStyle(color: SimcoreColors.textSecondary),
                    ),
                  ),
                ),
              );
            }
            final allCoursesAsync = ref.watch(coursesProvider);
            return allCoursesAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => GlassPanel(
                child: Center(
                  child: Text(
                    'Error al cargar cursos: ${toUserFriendlyError(err)}',
                    style: const TextStyle(color: SimcoreColors.danger),
                  ),
                ),
              ),
              data: (courses) {
                return usersAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (err, _) => GlassPanel(
                    child: Center(
                      child: Text(
                        'Error al cargar usuarios: ${toUserFriendlyError(err)}',
                        style: const TextStyle(color: SimcoreColors.danger),
                      ),
                    ),
                  ),
                  data: (users) {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: groups.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        final courseId = (group['courseId'] as num?)?.toInt() ?? 0;
                        final course = courses.where((c) => c['id'] == courseId).firstOrNull;

                        return _GroupAdminCard(
                          group: group,
                          course: course,
                          users: users,
                        );
                      },
                    );
                  },
                );
              },
            );
          },
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
                        ?.map((r) =>
                            r.toString().toUpperCase().replaceAll('ROLE_', ''))
                        .toList() ??
                    [];
                return roles.contains('ESTUDIANTE');
              }).toList();

              if (students.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('No hay estudiantes disponibles.',
                      style: TextStyle(color: SimcoreColors.warning)),
                );
              }

              return _CompactActionRow(
                field: DropdownButtonFormField<int>(
                  initialValue: _selectedMemberId,
                  decoration: const InputDecoration(
                      labelText: 'Selecciona Estudiante', isDense: true),
                  items: students.map((s) {
                    final id = s['id'] as int? ?? 0;
                    final name =
                        '${s['firstName'] ?? ''} ${s['lastName'] ?? ''}'.trim();
                    final username = s['username'] ?? '';
                    final displayName =
                        name.isNotEmpty ? '$name ($username)' : username;
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
                action: IconButton.filled(
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
                      final name =
                          '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'
                              .trim();
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
              label: Text('Agregar ${widget.pendingMembers.length} miembro(s)'),
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

              return _CompactActionRow(
                field: DropdownButtonFormField<int>(
                  initialValue: _selectedCompanyId,
                  decoration: const InputDecoration(
                      labelText: 'Selecciona Empresa', isDense: true),
                  items: companies.map((c) {
                    return DropdownMenuItem<int>(
                      value: c.id,
                      child: Text(c.name),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedCompanyId = v;
                    });
                  },
                ),
                action: OutlinedButton(
                  onPressed: _selectedCompanyId == null
                      ? null
                      : () =>
                          widget.onLinkCompany(groupId, _selectedCompanyId!),
                  child: const Text('Vincular'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CompactActionRow extends StatelessWidget {
  const _CompactActionRow({
    required this.field,
    required this.action,
  });

  final Widget field;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 420) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              field,
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight, child: action),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: field),
            const SizedBox(width: 8),
            action,
          ],
        );
      },
    );
  }
}

class _GroupAdminCard extends ConsumerWidget {
  const _GroupAdminCard({
    required this.group,
    required this.course,
    required this.users,
  });

  final Map<String, dynamic> group;
  final Map<String, dynamic>? course;
  final List<Map<String, dynamic>> users;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupId = group['id'] as int? ?? 0;
    final name = group['name'] ?? '';
    final courseId = (group['courseId'] as num?)?.toInt() ?? 0;
    final companyId = (group['companyId'] as num?)?.toInt();

    final courseName = course != null ? (course!['name'] ?? course!['title'] ?? '') : 'Curso desconocido';
    final courseCode = course != null ? (course!['code'] ?? '') : '';
    final teacherName = course != null ? (course!['teacherName'] ?? 'No asignado') : 'No asignado';

    final rawMemberIds = group['memberIds'];
    final Set<int> memberIds = {};
    if (rawMemberIds is Iterable) {
      memberIds.addAll(rawMemberIds.map((id) => (id as num).toInt()));
    }

    final groupMembers = users.where((u) {
      final uid = u['id'] as int? ?? 0;
      return memberIds.contains(uid);
    }).toList();

    AsyncValue<String?> companyNameAsync = const AsyncValue.data(null);
    if (companyId != null) {
      companyNameAsync = ref.watch(companiesByCourseProvider(courseId)).whenData((companies) {
        final comp = companies.where((c) => c.id == companyId).firstOrNull;
        return comp?.name;
      });
    }

    return GlassPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.group_work_rounded,
                  color: SimcoreColors.accent, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: SimcoreColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: SimcoreColors.accentSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${groupMembers.length} integrantes',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: SimcoreColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.school_outlined,
                  size: 18, color: SimcoreColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 14, color: SimcoreColors.textSecondary),
                    children: [
                      const TextSpan(
                        text: 'Curso: ',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: SimcoreColors.textPrimary),
                      ),
                      TextSpan(text: '$courseName ($courseCode)\n'),
                      const TextSpan(
                        text: 'Docente: ',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: SimcoreColors.textPrimary),
                      ),
                      TextSpan(text: teacherName),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.business_rounded,
                  size: 18, color: SimcoreColors.textSecondary),
              const SizedBox(width: 8),
              const Text(
                'Empresa: ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: SimcoreColors.textPrimary,
                ),
              ),
              if (companyId == null)
                const Text(
                  'Sin empresa vinculada',
                  style: TextStyle(
                    fontSize: 14,
                    color: SimcoreColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                companyNameAsync.when(
                  data: (cName) => Text(
                    cName ?? 'Desconocida',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: SimcoreColors.success,
                    ),
                  ),
                  loading: () => const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.5, color: SimcoreColors.accent),
                  ),
                  error: (_, __) => const Text(
                    'Error al cargar empresa',
                    style: TextStyle(
                        fontSize: 14, color: SimcoreColors.danger),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Estudiantes Integrantes:',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: SimcoreColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          if (groupMembers.isEmpty)
            const Text(
              'No hay integrantes asignados a este grupo.',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: SimcoreColors.textTertiary,
              ),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: groupMembers.map((m) {
                final fname = m['firstName'] ?? '';
                final lname = m['lastName'] ?? '';
                final username = m['username'] ?? '';
                final name = '$fname $lname'.trim();
                final displayName = name.isNotEmpty ? name : username;

                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: SimcoreColors.border),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_outline_rounded,
                          size: 14, color: SimcoreColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: SimcoreColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('¿Eliminar del grupo?'),
                              content: Text('¿Deseas eliminar a $displayName de este grupo?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  style: TextButton.styleFrom(foregroundColor: SimcoreColors.danger),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            final studentId = m['id'] as int? ?? 0;
                            await ref.read(groupNotifierProvider.notifier).removeMember(
                              groupId: groupId,
                              studentId: studentId,
                            );
                            ref.invalidate(allGroupsProvider);
                            if (context.mounted) {
                              showSimcoreSuccessDialog(
                                context: context,
                                title: '¡Miembro Eliminado!',
                                message: '$displayName ha sido eliminado del grupo correctamente.',
                              );
                            }
                          }
                        },
                        child: Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
