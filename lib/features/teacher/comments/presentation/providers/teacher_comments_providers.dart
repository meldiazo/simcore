import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';
import 'package:simcore_frontend/features/teacher/comments/data/datasources/teacher_comments_remote_datasource.dart';

final commentsProvider =
    FutureProvider.family.autoDispose<List<Map<String, dynamic>>, String>(
        (ref, module) async {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return [];
  return ref
      .watch(teacherCommentsDataSourceProvider)
      .getComments(companyId: ctx.companyId, module: module);
});

// ── Comments Notifier ─────────────────────────────────────────────────────────

class CommentsNotifier extends StateNotifier<AsyncValue<void>> {
  CommentsNotifier(this._ds, this._ref) : super(const AsyncValue.data(null));

  final TeacherCommentsRemoteDataSource _ds;
  final Ref _ref;

  int get _companyId {
    final ctx = _ref.read(simulationContextNotifierProvider).context;
    if (ctx == null) throw StateError('No simulation context');
    return ctx.companyId;
  }

  Future<void> addComment({
    required String module,
    required String content,
    required String visibility,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _ds.addComment(
        companyId: _companyId,
        module: module,
        content: content,
        visibility: visibility,
      );
      _ref.invalidate(commentsProvider(module));
    });
  }

  Future<void> updateComment({
    required String module,
    required int commentId,
    required String content,
    required String visibility,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _ds.updateComment(
        companyId: _companyId,
        commentId: commentId,
        content: content,
        visibility: visibility,
      );
      _ref.invalidate(commentsProvider(module));
    });
  }

  Future<void> deleteComment({
    required String module,
    required int commentId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _ds.deleteComment(
        companyId: _companyId,
        commentId: commentId,
      );
      _ref.invalidate(commentsProvider(module));
    });
  }
}

final commentsNotifierProvider =
    StateNotifierProvider.autoDispose<CommentsNotifier, AsyncValue<void>>(
  (ref) => CommentsNotifier(
    ref.watch(teacherCommentsDataSourceProvider),
    ref,
  ),
);
