import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/validation/form_validators.dart';
import 'package:simcore_frontend/features/academic/presentation/providers/academic_providers.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/form_error_summary.dart';

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
      setState(() => _fieldErrors = {'error': 'Por favor, selecciona un docente.'});
      return;
    }

    setState(() => _fieldErrors = {});

    try {
      await ref.read(courseNotifierProvider.notifier).createCourse(
            code: _codeCtrl.text.trim(),
            name: _nameCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            academicPeriod: _academicPeriodCtrl.text.trim(),
            teacherId: _selectedTeacherId!,
          );
    } catch (e) {
      setState(() => _fieldErrors = {'error': e.toString()});
    }
  }

  Future<void> _closeCourse(int id) async {
    await ref.read(courseNotifierProvider.notifier).closeCourse(id);
  }

  Future<void> _enrollStudents(int courseId) async {
    if (_pendingStudentIds.isEmpty) return;
    await ref.read(courseNotifierProvider.notifier).enrollStudents(
          courseId: courseId,
          studentIds: _pendingStudentIds,
        );
    setState(() => _pendingStudentIds.clear());
  }

  @override
  Widget build(BuildContext context) {
    final courseState = ref.watch(courseNotifierProvider);
    final usersAsync = ref.watch(usersProvider);

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
                  decoration: const InputDecoration(labelText: 'Código del curso (ej: ADM-101)'),
                  validator: (v) => FormValidators.required(v, fieldName: 'Código del curso'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre del curso'),
                  validator: (v) =>
                      FormValidators.minLength(v, 3, fieldName: 'Nombre del curso'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 2,
                  validator: (v) => FormValidators.required(v, fieldName: 'Descripción'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _academicPeriodCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Periodo académico',
                    hintText: 'Ejemplo: 2026-I',
                  ),
                ),
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
                          ?.map((r) => r.toString().toUpperCase().replaceAll('ROLE_', ''))
                          .toList() ?? [];
                      return roles.contains('DOCENTE');
                    }).toList();

                    if (teachers.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text('No hay docentes disponibles en el sistema.',
                            style: TextStyle(color: SimcoreColors.warning)),
                      );
                    }

                    return DropdownButtonFormField<int>(
                      initialValue: _selectedTeacherId,
                      decoration: const InputDecoration(labelText: 'Selecciona Docente'),
                      items: teachers.map((t) {
                        final id = t['id'] as int? ?? 0;
                        final name = '${t['firstName'] ?? ''} ${t['lastName'] ?? ''}'.trim();
                        final username = t['username'] ?? '';
                        final displayName = name.isNotEmpty ? '$name ($username)' : username;
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
                      validator: (v) => v == null ? 'Selecciona un docente' : null,
                    );
                  },
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: courseState.isLoading ? null : _create,
                  icon: courseState.isLoading
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.add_rounded),
                  label: const Text('Crear Curso'),
                ),
              ],
            ),
          ),
        ),
        if (courseState.hasValue && courseState.value != null) ...[
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
            onRemoveStudent: (id) => setState(() => _pendingStudentIds.remove(id)),
          ),
        ],
        if (courseState.hasError)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              courseState.error.toString(),
              style: const TextStyle(color: SimcoreColors.danger),
            ),
          ),
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
              const Icon(Icons.check_circle_rounded, color: SimcoreColors.success),
              const SizedBox(width: 8),
              Text(
                'Curso #$id creado: ${widget.data['name'] ?? widget.data['title'] ?? ''}',
                style: const TextStyle(fontWeight: FontWeight.w700),
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
                      initialValue: _selectedStudentId,
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
                          _selectedStudentId = v;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
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
                ],
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
                      final name = '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim();
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
              label: Text('Matricular ${widget.pendingStudents.length} estudiante(s)'),
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
