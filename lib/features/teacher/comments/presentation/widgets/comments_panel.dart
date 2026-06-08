import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/auth/presentation/providers/auth_notifier.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/features/teacher/comments/presentation/providers/teacher_comments_providers.dart';

class CommentsPanel extends ConsumerStatefulWidget {
  const CommentsPanel({super.key, required this.module});

  final String module;

  @override
  ConsumerState<CommentsPanel> createState() => _CommentsPanelState();
}

class _CommentsPanelState extends ConsumerState<CommentsPanel> {
  final _contentCtrl = TextEditingController();
  String _visibility = 'PUBLIC';
  int? _editingId;

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) return;
    final notifier = ref.read(commentsNotifierProvider.notifier);
    if (_editingId != null) {
      await notifier.updateComment(
        module: widget.module,
        commentId: _editingId!,
        content: content,
        visibility: _visibility,
      );
      setState(() => _editingId = null);
    } else {
      await notifier.addComment(
        module: widget.module,
        content: content,
        visibility: _visibility,
      );
    }
    _contentCtrl.clear();
  }

  void _startEdit(Map<String, dynamic> comment) {
    setState(() {
      _editingId = comment['id'] as int?;
      _contentCtrl.text = (comment['content'] ?? '').toString();
      _visibility = (comment['visibility'] ?? 'PUBLIC').toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final commentsAsync = ref.watch(commentsProvider(widget.module));
    final isTeacher = user != null && (user.isAdmin || user.isDocente);
    final currentUserId = user?.id;

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Comentarios Docentes',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          commentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e',
                style: const TextStyle(color: SimcoreColors.danger)),
            data: (comments) {
              if (comments.isEmpty) {
                return const Text('Sin comentarios aún.',
                    style: TextStyle(color: SimcoreColors.textSecondary));
              }
              final publicComments = comments
                  .where((c) =>
                      (c['visibility'] ?? 'PUBLIC').toString().toUpperCase() ==
                      'PUBLIC')
                  .toList();
              final privateComments = comments
                  .where((c) =>
                      (c['visibility'] ?? 'PUBLIC').toString().toUpperCase() !=
                      'PUBLIC')
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (publicComments.isNotEmpty) ...[
                    const _SectionLabel('Comentarios Públicos'),
                    ...publicComments.map((c) => _CommentTile(
                          comment: c,
                          currentUserId: currentUserId,
                          onEdit: () => _startEdit(c),
                          onDelete: () => ref
                              .read(commentsNotifierProvider.notifier)
                              .deleteComment(
                                module: widget.module,
                                commentId: c['id'] as int,
                              ),
                        )),
                  ],
                  if (isTeacher && privateComments.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const _SectionLabel('Comentarios Privados (solo docentes)'),
                    ...privateComments.map((c) => _CommentTile(
                          comment: c,
                          currentUserId: currentUserId,
                          onEdit: () => _startEdit(c),
                          onDelete: () => ref
                              .read(commentsNotifierProvider.notifier)
                              .deleteComment(
                                module: widget.module,
                                commentId: c['id'] as int,
                              ),
                        )),
                  ],
                ],
              );
            },
          ),
          if (isTeacher) ...[
            const Divider(height: 24),
            Text(
              _editingId != null ? 'Editar comentario' : 'Nuevo comentario',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Escribe tu comentario...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Visibilidad: '),
                ChoiceChip(
                  label: const Text('Público'),
                  selected: _visibility == 'PUBLIC',
                  onSelected: (_) => setState(() => _visibility = 'PUBLIC'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Privado'),
                  selected: _visibility == 'PRIVATE',
                  onSelected: (_) => setState(() => _visibility = 'PRIVATE'),
                ),
                const Spacer(),
                if (_editingId != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _editingId = null;
                        _contentCtrl.clear();
                        _visibility = 'PUBLIC';
                      });
                    },
                    child: const Text('Cancelar'),
                  ),
                FilledButton(
                  onPressed: _submit,
                  child: Text(_editingId != null ? 'Guardar' : 'Publicar'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: SimcoreColors.textTertiary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.currentUserId,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> comment;
  final int? currentUserId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isAuthor = comment['authorId'] != null &&
        comment['authorId'] == currentUserId;
    final visibility =
        (comment['visibility'] ?? 'PUBLIC').toString().toUpperCase();
    final isPrivate = visibility != 'PUBLIC';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPrivate
            ? const Color(0xFFF59E0B).withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrivate
              ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
              : SimcoreColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPrivate ? Icons.lock_rounded : Icons.public_rounded,
                size: 14,
                color: isPrivate
                    ? const Color(0xFFF59E0B)
                    : SimcoreColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                (comment['authorName'] ?? 'Docente').toString(),
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const Spacer(),
              if (isAuthor) ...[
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: SimcoreColors.textSecondary,
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_rounded, size: 16),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: SimcoreColors.danger,
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            (comment['content'] ?? '').toString(),
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}
