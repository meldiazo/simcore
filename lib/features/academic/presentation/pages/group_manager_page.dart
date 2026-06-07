import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/validation/form_validators.dart';
import 'package:simcore_frontend/features/academic/presentation/providers/academic_providers.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/form_error_summary.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';

class GroupManagerPage extends ConsumerStatefulWidget {
  const GroupManagerPage({super.key});

  @override
  ConsumerState<GroupManagerPage> createState() => _GroupManagerPageState();
}

class _GroupManagerPageState extends ConsumerState<GroupManagerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _courseIdCtrl = TextEditingController();
  final _memberIdCtrl = TextEditingController();
  final _companyIdCtrl = TextEditingController();
  final List<int> _pendingMemberIds = [];
  Map<String, String> _fieldErrors = {};

  @override
  void dispose() {
    _nameCtrl.dispose();
    _courseIdCtrl.dispose();
    _memberIdCtrl.dispose();
    _companyIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _fieldErrors = {});
    try {
      await ref.read(groupNotifierProvider.notifier).createGroup(
            name: _nameCtrl.text.trim(),
            courseId: int.parse(_courseIdCtrl.text.trim()),
          );
    } catch (e) {
      setState(() => _fieldErrors = {'error': e.toString()});
    }
  }

  void _addMemberId() {
    final id = int.tryParse(_memberIdCtrl.text.trim());
    if (id != null && !_pendingMemberIds.contains(id)) {
      setState(() {
        _pendingMemberIds.add(id);
        _memberIdCtrl.clear();
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

  Future<void> _linkCompany(int groupId) async {
    final companyId = int.tryParse(_companyIdCtrl.text.trim());
    if (companyId == null) return;
    await ref.read(groupNotifierProvider.notifier).linkCompany(
          groupId: groupId,
          companyId: companyId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupNotifierProvider);

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
                const SizedBox(height: 12),
                TextFormField(
                  controller: _courseIdCtrl,
                  decoration: const InputDecoration(labelText: 'ID del Curso'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      FormValidators.positiveInt(v, fieldName: 'ID Curso'),
                ),
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
            memberIdCtrl: _memberIdCtrl,
            companyIdCtrl: _companyIdCtrl,
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

class _GroupResultPanel extends StatelessWidget {
  const _GroupResultPanel({
    required this.data,
    required this.memberIdCtrl,
    required this.companyIdCtrl,
    required this.pendingMembers,
    required this.onAddMember,
    required this.onRemoveMember,
    required this.onSendMembers,
    required this.onLinkCompany,
  });

  final Map<String, dynamic> data;
  final TextEditingController memberIdCtrl;
  final TextEditingController companyIdCtrl;
  final List<int> pendingMembers;
  final VoidCallback onAddMember;
  final void Function(int id) onRemoveMember;
  final void Function(int groupId) onSendMembers;
  final void Function(int groupId) onLinkCompany;

  @override
  Widget build(BuildContext context) {
    final groupId = data['id'] as int? ?? 0;
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
          Text(
            'Comparte este ID con los estudiantes del grupo.',
            style: const TextStyle(color: SimcoreColors.textSecondary),
          ),
          const Divider(height: 24),

          // Agregar miembros
          const Text('Agregar Miembros',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: memberIdCtrl,
                  decoration: const InputDecoration(
                      labelText: 'ID Usuario', isDense: true),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: onAddMember,
                icon: const Icon(Icons.person_add_rounded),
              ),
            ],
          ),
          if (pendingMembers.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: pendingMembers
                  .map((m) => Chip(
                        label: Text('$m'),
                        deleteIcon:
                            const Icon(Icons.close_rounded, size: 14),
                        onDeleted: () => onRemoveMember(m),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => onSendMembers(groupId),
              icon: const Icon(Icons.group_add_rounded),
              label:
                  Text('Agregar ${pendingMembers.length} miembro(s)'),
            ),
          ],

          const Divider(height: 24),

          // Vincular empresa
          const Text('Vincular Empresa',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: companyIdCtrl,
                  decoration: const InputDecoration(
                      labelText: 'ID Empresa', isDense: true),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => onLinkCompany(groupId),
                child: const Text('Vincular'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
