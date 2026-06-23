import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/features/academic/data/datasources/academic_remote_datasource.dart';
import 'package:simcore_frontend/features/auth/presentation/providers/auth_notifier.dart';

// ── Course Notifier ────────────────────────────────────────────────────────────

class CourseNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
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

final coursesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final ds = ref.watch(academicDataSourceProvider);
  final authState = ref.watch(authNotifierProvider);
  final courses = await ds.listCourses();
  final user = authState.user;
  if (user != null && user.isDocente) {
    return courses.where((c) {
      final tId = c['teacherId'] ?? c['teacher']?['id'];
      return tId == user.id;
    }).toList();
  }
  return courses;
});

final allGroupsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final ds = ref.watch(academicDataSourceProvider);
  final courses = await ref.watch(coursesProvider.future);
  final groups = <Map<String, dynamic>>[];

  for (final course in courses) {
    final rawId = course['id'];
    final courseId = rawId is int ? rawId : int.tryParse('$rawId');
    if (courseId == null) continue;

    final courseGroups = await ds.listGroups(courseId: courseId);
    groups.addAll(courseGroups);
  }

  return groups;
});

final groupsByCourseProvider = FutureProvider.family
    .autoDispose<List<Map<String, dynamic>>, int>((ref, courseId) async {
  final ds = ref.watch(academicDataSourceProvider);
  return ds.listGroups(courseId: courseId);
});

// ── Group Notifier ─────────────────────────────────────────────────────────────

class GroupNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
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

final usersProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final ds = ref.watch(academicDataSourceProvider);
  return ds.listUsers();
});

final rolesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final ds = ref.watch(academicDataSourceProvider);
  return ds.listRoles();
});

class UserAdminNotifier extends StateNotifier<AsyncValue<void>> {
  UserAdminNotifier(this._ds, this._ref) : super(const AsyncValue.data(null));

  final AcademicRemoteDataSource _ds;
  final Ref _ref;

  Future<bool> updateRoles({
    required int userId,
    required List<int> roleIds,
  }) async {
    return _run(() => _ds.updateUserRoles(userId: userId, roleIds: roleIds));
  }

  Future<bool> setEnabled({
    required int userId,
    required bool enabled,
  }) async {
    return _run(
        () => enabled ? _ds.enableUser(userId) : _ds.disableUser(userId));
  }

  Future<bool> _run(Future<Map<String, dynamic>> Function() action) async {
    state = const AsyncValue.loading();
    try {
      await action();
      if (!mounted) return false;
      state = const AsyncValue.data(null);
      _ref.invalidate(usersProvider);
      return true;
    } catch (e, st) {
      if (!mounted) return false;
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final userAdminNotifierProvider =
    StateNotifierProvider<UserAdminNotifier, AsyncValue<void>>((ref) {
  return UserAdminNotifier(ref.watch(academicDataSourceProvider), ref);
});
