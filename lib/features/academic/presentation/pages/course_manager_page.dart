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
final _teacherIdCtrl = TextEditingController();
final _studentIdCtrl = TextEditingController();
  final List<int> _pendingStudentIds = [];
  Map<String, String> _fieldErrors = {};

  @override
void dispose() {
  _codeCtrl.dispose();
  _nameCtrl.dispose();
  _descCtrl.dispose();
  _academicPeriodCtrl.dispose();
  _teacherIdCtrl.dispose();
  _studentIdCtrl.dispose();
  super.dispose();
}

  Future<void> _create() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _fieldErrors = {});

  try {
    await ref.read(courseNotifierProvider.notifier).createCourse(
          code: _codeCtrl.text.trim(),
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          academicPeriod: _academicPeriodCtrl.text.trim(),
          teacherId: int.parse(_teacherIdCtrl.text.trim()),
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

  void _addStudentId() {
    final id = int.tryParse(_studentIdCtrl.text.trim());
    if (id != null && !_pendingStudentIds.contains(id)) {
      setState(() {
        _pendingStudentIds.add(id);
        _studentIdCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseState = ref.watch(courseNotifierProvider);

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
                  decoration: const InputDecoration(labelText: 'Código'),
                  validator: (v) => FormValidators.required(v, fieldName: 'Código'),
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
TextFormField(
  controller: _teacherIdCtrl,
                  decoration: const InputDecoration(labelText: 'ID Docente'),
                  keyboardType: TextInputType.number,
                  validator: (v) => FormValidators.positiveInt(v, fieldName: 'ID Docente'),
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
            studentIdCtrl: _studentIdCtrl,
            pendingStudents: _pendingStudentIds,
            onAddStudent: _addStudentId,
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

class _CourseResultPanel extends StatelessWidget {
  const _CourseResultPanel({
    required this.data,
    required this.onClose,
    required this.onEnroll,
    required this.studentIdCtrl,
    required this.pendingStudents,
    required this.onAddStudent,
    required this.onRemoveStudent,
  });

  final Map<String, dynamic> data;
  final void Function(int id) onClose;
  final void Function(int id) onEnroll;
  final TextEditingController studentIdCtrl;
  final List<int> pendingStudents;
  final VoidCallback onAddStudent;
  final void Function(int id) onRemoveStudent;

  @override
  Widget build(BuildContext context) {
    final id = data['id'] as int? ?? 0;
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: SimcoreColors.success),
              const SizedBox(width: 8),
              Text(
  'Curso #$id creado: ${data['name'] ?? data['title'] ?? ''}',
  style: const TextStyle(fontWeight: FontWeight.w700),
),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Matricular Estudiantes',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: studentIdCtrl,
                  decoration: const InputDecoration(
                      labelText: 'ID Estudiante', isDense: true),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: onAddStudent,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          if (pendingStudents.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: pendingStudents
                  .map((s) => Chip(
                        label: Text('$s'),
                        deleteIcon: const Icon(Icons.close_rounded, size: 14),
                        onDeleted: () => onRemoveStudent(s),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => onEnroll(id),
              icon: const Icon(Icons.group_add_rounded),
              label: Text('Matricular ${pendingStudents.length} estudiante(s)'),
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => onClose(id),
            icon: const Icon(Icons.lock_rounded, color: SimcoreColors.danger),
            label: const Text('Cerrar Curso',
                style: TextStyle(color: SimcoreColors.danger)),
          ),
        ],
      ),
    );
  }
}
