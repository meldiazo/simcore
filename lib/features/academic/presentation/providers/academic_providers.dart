import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/features/academic/data/datasources/academic_remote_datasource.dart';

// ── Course Notifier ────────────────────────────────────────────────────────────

class CourseNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  CourseNotifier(this._ds) : super(const AsyncValue.data(null));

  final AcademicRemoteDataSource _ds;

  Future<void> createCourse({
  required String code,
  required String name,
  required String description,
  String? academicPeriod,
  required int teacherId,
}) async {
  state = const AsyncValue.loading();
  state = await AsyncValue.guard(() => _ds.createCourse(
        code: code,
        name: name,
        description: description,
        academicPeriod: academicPeriod,
        teacherId: teacherId,
      ));
}

  Future<void> getCourse(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _ds.getCourse(id));
  }

  Future<void> closeCourse(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _ds.closeCourse(id));
  }

  Future<void> enrollStudents({
    required int courseId,
    required List<int> studentIds,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _ds.enrollStudents(courseId: courseId, studentIds: studentIds));
  }
}

final courseNotifierProvider = StateNotifierProvider.autoDispose<CourseNotifier,
    AsyncValue<Map<String, dynamic>?>>(
  (ref) => CourseNotifier(ref.watch(academicDataSourceProvider)),
);

// ── Group Notifier ─────────────────────────────────────────────────────────────

class GroupNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  GroupNotifier(this._ds) : super(const AsyncValue.data(null));

  final AcademicRemoteDataSource _ds;

  Future<void> createGroup({
    required String name,
    required int courseId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _ds.createGroup(name: name, courseId: courseId));
  }

  Future<void> getGroup(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _ds.getGroup(id));
  }

  Future<void> addMembers({
    required int groupId,
    required List<int> memberIds,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _ds.addGroupMembers(groupId: groupId, memberIds: memberIds));
  }

  Future<void> removeMember({
    required int groupId,
    required int studentId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _ds.removeGroupMember(groupId: groupId, studentId: studentId);
      return <String, dynamic>{};
    });
  }

  Future<void> linkCompany({
    required int groupId,
    required int companyId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _ds.linkGroupCompany(groupId: groupId, companyId: companyId));
  }
}

final groupNotifierProvider = StateNotifierProvider.autoDispose<GroupNotifier,
    AsyncValue<Map<String, dynamic>?>>(
  (ref) => GroupNotifier(ref.watch(academicDataSourceProvider)),
);
