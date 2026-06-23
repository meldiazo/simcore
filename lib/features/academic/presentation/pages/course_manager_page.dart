import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/validation/form_validators.dart';
import 'package:simcore_frontend/features/academic/presentation/providers/academic_providers.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/features/auth/presentation/providers/auth_notifier.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/form_error_summary.dart';
import 'package:simcore_frontend/core/error/error_utils.dart';


class CourseManagerPage extends ConsumerStatefulWidget {
  const CourseManagerPage({super.key});

  @override
  ConsumerState<CourseManagerPage> createState() => _CourseManagerPageState();
}

class _CourseManagerPageState extends ConsumerState<CourseManagerPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _academicPeriodCtrl = TextEditingController();
  final List<int> _pendingStudentIds = [];
  Map<String, String> _fieldErrors = {};
  int? _selectedTeacherId;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _academicPeriodCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTeacherId == null) {
      setState(
          () => _fieldErrors = {'error': 'Por favor, selecciona un docente.'});
      return;
    }

    setState(() => _fieldErrors = {});

    await ref.read(courseNotifierProvider.notifier).createCourse(
          code: _codeCtrl.text.trim(),
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          academicPeriod: _academicPeriodCtrl.text.trim(),
          teacherId: _selectedTeacherId!,
        );
    if (!mounted) return;

    final courseState = ref.read(courseNotifierProvider);
    if (courseState.hasError) {
      setState(() {
        final errorMsg = courseState.error.toString();
        final cleanMsg = errorMsg.startsWith('Exception: ')
            ? errorMsg.substring(11)
            : errorMsg;
        _fieldErrors = {'error': cleanMsg};
      });
    } else {
      ref.invalidate(coursesProvider);
      showSimcoreSuccessDialog(
        context: context,
        title: '¡Curso Creado!',
        message: 'El curso ${_nameCtrl.text.trim()} (${_codeCtrl.text.trim()}) ha sido registrado exitosamente.',
      );
      _codeCtrl.clear();
      _nameCtrl.clear();
      _descCtrl.clear();
      _academicPeriodCtrl.clear();
    }
  }

  Future<void> _closeCourse(int id) async {
    await ref.read(courseNotifierProvider.notifier).closeCourse(id);
    if (!mounted) return;

    final courseState = ref.read(courseNotifierProvider);
    if (courseState.hasError) {
      setState(() {
        _fieldErrors = {'error': courseState.error.toString()};
      });
    } else {
      ref.invalidate(coursesProvider);
      showSimcoreSuccessDialog(
        context: context,
        title: '¡Curso Cerrado!',
        message: 'El curso ha sido cerrado y archivado exitosamente.',
      );
    }
  }

  Future<void> _enrollStudents(int courseId) async {
    if (_pendingStudentIds.isEmpty) return;
    await ref.read(courseNotifierProvider.notifier).enrollStudents(
          courseId: courseId,
          studentIds: _pendingStudentIds,
        );
    if (!mounted) return;

    final courseState = ref.read(courseNotifierProvider);
    if (courseState.hasError) {
      setState(() {
        _fieldErrors = {'error': courseState.error.toString()};
      });
    } else {
      showSimcoreSuccessDialog(
        context: context,
        title: '¡Estudiantes Matriculados!',
        message: 'Los estudiantes seleccionados han sido matriculados en el curso exitosamente.',
      );
      setState(() => _pendingStudentIds.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseState = ref.watch(courseNotifierProvider);
    final usersAsync = ref.watch(usersProvider);
    final currentUser = ref.watch(authNotifierProvider).user;
    final isTeacher = currentUser?.isDocente == true;
    final isAdmin = currentUser?.isAdmin == true;

    if (isTeacher && _selectedTeacherId == null) {
      _selectedTeacherId = currentUser!.id;
    }

    if (isAdmin) {
      final coursesAsync = ref.watch(coursesProvider);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageIntro(
            title: 'Gestión de Cursos',
            subtitle: 'Lista de todos los cursos, docentes, alumnos y grupos registrados.',
          ),
          const SizedBox(height: 24),
          coursesAsync.when(
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
              if (courses.isEmpty) {
                return const GlassPanel(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No hay cursos registrados en el sistema.',
                        style: TextStyle(color: SimcoreColors.textSecondary),
                      ),
                    ),
                  ),
                );
              }
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
                      'Error al cargar estudiantes: ${toUserFriendlyError(err)}',
                      style: const TextStyle(color: SimcoreColors.danger),
                    ),
                  ),
                ),
                data: (users) {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return _CourseAdminCard(
                        course: course,
                        users: users,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageIntro(
          title: 'Gestión de Cursos',
          subtitle: 'Crear y administrar cursos académicos.',
        ),
        const SizedBox(height: 24),
        GlassPanel(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Crear Curso',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 16),
                FormErrorSummary(errors: _fieldErrors),
                TextFormField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Código del curso (ej: ADM-101)'),
                  validator: (v) =>
                      FormValidators.required(v, fieldName: 'Código del curso'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Nombre del curso'),
                  validator: (v) => FormValidators.minLength(v, 3,
                      fieldName: 'Nombre del curso'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 2,
                  validator: (v) =>
                      FormValidators.required(v, fieldName: 'Descripción'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _academicPeriodCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Periodo académico',
                    hintText: 'Ejemplo: 2026-I',
                  ),
                ),
                if (!isTeacher) ...[
                  const SizedBox(height: 12),
                  usersAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, _) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('Error al cargar docentes: $err',
                          style: const TextStyle(color: SimcoreColors.danger)),
                    ),
                    data: (users) {
                      final teachers = users.where((u) {
                        final roles = (u['roles'] as List?)
                                ?.map((r) => r
                                    .toString()
                                    .toUpperCase()
                                    .replaceAll('ROLE_', ''))
                                .toList() ??
                            [];
                        return roles.contains('DOCENTE');
                      }).toList();

                      if (teachers.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                              'No hay docentes disponibles en el sistema.',
                              style: TextStyle(color: SimcoreColors.warning)),
                        );
                      }

                      return DropdownButtonFormField<int>(
                        initialValue: _selectedTeacherId,
                        decoration: const InputDecoration(
                            labelText: 'Selecciona Docente'),
                        items: teachers.map((t) {
                          final id = t['id'] as int? ?? 0;
                          final name =
                              '${t['firstName'] ?? ''} ${t['lastName'] ?? ''}'
                                  .trim();
                          final username = t['username'] ?? '';
                          final displayName =
                              name.isNotEmpty ? '$name ($username)' : username;
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(displayName),
                          );
                        }).toList(),
                        onChanged: (v) {
                          setState(() {
                            _selectedTeacherId = v;
                          });
                        },
                        validator: (v) =>
                            v == null ? 'Selecciona un docente' : null,
                      );
                    },
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: courseState.isLoading ? null : _create,
                  icon: courseState.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.add_rounded),
                  label: const Text('Crear Curso'),
                ),
              ],
            ),
          ),
        ),
        if (courseState is AsyncData && courseState.value != null) ...[
          const SizedBox(height: 20),
          _CourseResultPanel(
            data: courseState.value!,
            onClose: (id) => _closeCourse(id),
            onEnroll: (id) => _enrollStudents(id),
            pendingStudents: _pendingStudentIds,
            onAddStudent: (id) {
              if (!_pendingStudentIds.contains(id)) {
                setState(() {
                  _pendingStudentIds.add(id);
                });
              }
            },
            onRemoveStudent: (id) =>
                setState(() => _pendingStudentIds.remove(id)),
          ),
        ],
        const SizedBox(height: 28),
      ],
    );
  }
}

class _CourseResultPanel extends ConsumerStatefulWidget {
  const _CourseResultPanel({
    required this.data,
    required this.onClose,
    required this.onEnroll,
    required this.pendingStudents,
    required this.onAddStudent,
    required this.onRemoveStudent,
  });

  final Map<String, dynamic> data;
  final void Function(int id) onClose;
  final void Function(int id) onEnroll;
  final List<int> pendingStudents;
  final void Function(int id) onAddStudent;
  final void Function(int id) onRemoveStudent;

  @override
  ConsumerState<_CourseResultPanel> createState() => _CourseResultPanelState();
}

class _CourseResultPanelState extends ConsumerState<_CourseResultPanel> {
  int? _selectedStudentId;

  @override
  Widget build(BuildContext context) {
    final id = widget.data['id'] as int? ?? 0;
    final usersAsync = ref.watch(usersProvider);

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
                  'Curso #$id creado: ${widget.data['name'] ?? widget.data['title'] ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Matricular Estudiantes',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          usersAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('Error al cargar estudiantes: $err',
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
                  initialValue: _selectedStudentId,
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
                      _selectedStudentId = v;
                    });
                  },
                ),
                action: IconButton.filled(
                  onPressed: _selectedStudentId == null
                      ? null
                      : () {
                          widget.onAddStudent(_selectedStudentId!);
                          setState(() {
                            _selectedStudentId = null;
                          });
                        },
                  icon: const Icon(Icons.add_rounded),
                ),
              );
            },
          ),
          if (widget.pendingStudents.isNotEmpty) ...[
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
                  children: widget.pendingStudents.map((s) {
                    final label = nameMap[s] ?? '$s';
                    return Chip(
                      label: Text(label),
                      deleteIcon: const Icon(Icons.close_rounded, size: 14),
                      onDeleted: () => widget.onRemoveStudent(s),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => widget.onEnroll(id),
              icon: const Icon(Icons.group_add_rounded),
              label: Text(
                  'Matricular ${widget.pendingStudents.length} estudiante(s)'),
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => widget.onClose(id),
            icon: const Icon(Icons.lock_rounded, color: SimcoreColors.danger),
            label: const Text('Cerrar Curso',
                style: TextStyle(color: SimcoreColors.danger)),
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

class _CourseAdminCard extends ConsumerWidget {
  const _CourseAdminCard({
    required this.course,
    required this.users,
  });

  final Map<String, dynamic> course;
  final List<Map<String, dynamic>> users;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseId = course['id'] as int? ?? 0;
    final code = course['code'] ?? '';
    final name = course['name'] ?? course['title'] ?? '';
    final desc = course['description'] ?? '';
    final period = course['academicPeriod'] ?? '';
    final teacherName = course['teacherName'] ?? 'No asignado';
    final status = course['status'] ?? 'ACTIVE';

    final rawStudentIds = course['studentIds'];
    final Set<int> studentIds = {};
    if (rawStudentIds is Iterable) {
      studentIds.addAll(rawStudentIds.map((id) => (id as num).toInt()));
    }

    final enrolledStudents = users.where((u) {
      final uid = u['id'] as int? ?? 0;
      return studentIds.contains(uid);
    }).toList();

    final groupsAsync = ref.watch(groupsByCourseProvider(courseId));

    return GlassPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: SimcoreColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: SimcoreColors.accentSoft,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            code,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: SimcoreColors.accent,
                            ),
                          ),
                        ),
                        if (period.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              period,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: SimcoreColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: status == 'ACTIVE'
                      ? SimcoreColors.successSoft
                      : SimcoreColors.dangerSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status == 'ACTIVE' ? 'Activo' : 'Cerrado',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: status == 'ACTIVE'
                        ? SimcoreColors.success
                        : SimcoreColors.danger,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (desc.isNotEmpty) ...[
            Text(
              desc,
              style: const TextStyle(
                fontSize: 14,
                color: SimcoreColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
          ],
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded,
                  size: 18, color: SimcoreColors.accent),
              const SizedBox(width: 8),
              const Text(
                'Docente: ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: SimcoreColors.textPrimary,
                ),
              ),
              Text(
                teacherName,
                style: const TextStyle(
                  fontSize: 14,
                  color: SimcoreColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Alumnos Matricados (${enrolledStudents.length})',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: SimcoreColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          if (enrolledStudents.isEmpty)
            const Text(
              'No hay alumnos matriculados en este curso.',
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
              children: enrolledStudents.map((s) {
                final fname = s['firstName'] ?? '';
                final lname = s['lastName'] ?? '';
                final username = s['username'] ?? '';
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
                      const Icon(Icons.school_outlined,
                          size: 14, color: SimcoreColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: SimcoreColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 16),
          const Text(
            'Grupos del Curso',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: SimcoreColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          groupsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (err, _) => Text(
              'Error al cargar grupos: $err',
              style: const TextStyle(color: SimcoreColors.danger, fontSize: 13),
            ),
            data: (groups) {
              if (groups.isEmpty) {
                return const Text(
                  'No hay grupos creados en este curso.',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: SimcoreColors.textTertiary,
                  ),
                );
              }
              return Column(
                children: groups.map((g) {
                  final groupName = g['name'] ?? '';
                  final rawMemberIds = g['memberIds'];
                  final Set<int> memberIds = {};
                  if (rawMemberIds is Iterable) {
                    memberIds.addAll(rawMemberIds.map((id) => (id as num).toInt()));
                  }

                  final groupMembers = users.where((u) {
                    final uid = u['id'] as int? ?? 0;
                    return memberIds.contains(uid);
                  }).toList();

                  final memberNames = groupMembers.map((m) {
                    final fname = m['firstName'] ?? '';
                    final lname = m['lastName'] ?? '';
                    final username = m['username'] ?? '';
                    final name = '$fname $lname'.trim();
                    return name.isNotEmpty ? name : username;
                  }).join(', ');

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(top: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: SimcoreColors.border),
                    ),
                    color: Colors.white.withValues(alpha: 0.5),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.group_work_outlined,
                                  size: 16, color: SimcoreColors.accent),
                              const SizedBox(width: 6),
                              Text(
                                groupName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: SimcoreColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: SimcoreColors.accentSoft,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${groupMembers.length} alumnos',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: SimcoreColors.accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (groupMembers.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              memberNames,
                              style: const TextStyle(
                                fontSize: 12,
                                color: SimcoreColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
