import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';

class AcademicRemoteDataSource {
  const AcademicRemoteDataSource(this._client);

  final ApiClient _client;

  // ── Cursos ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createCourse({
  required String code,
  required String name,
  required String description,
  String? academicPeriod,
  required int teacherId,
}) async {
  final payload = <String, dynamic>{
    'code': code,
    'name': name,
    'description': description,
    'teacherId': teacherId,
  };

  final normalizedAcademicPeriod = academicPeriod?.trim();
  if (normalizedAcademicPeriod != null &&
      normalizedAcademicPeriod.isNotEmpty) {
    payload['academicPeriod'] = normalizedAcademicPeriod;
  }

  final result = await _client.post(
    '/api/v1/iam/courses',
    data: payload,
  );

  return result.fold(
    (e) => throw Exception(e.message),
    (data) => Map<String, dynamic>.from(data as Map),
  );
}

  Future<Map<String, dynamic>> getCourse(int id) async {
    final result = await _client.get('/api/v1/iam/courses/$id');
    return result.fold(
      (e) => throw Exception(e.message),
      (data) => Map<String, dynamic>.from(data as Map),
    );
  }

  Future<Map<String, dynamic>> updateCourse({
    required int id,
    required String title,
    required String description,
  }) async {
    final result = await _client.put(
      '/api/v1/iam/courses/$id',
      data: {'title': title, 'description': description},
    );
    return result.fold(
      (e) => throw Exception(e.message),
      (data) => Map<String, dynamic>.from(data as Map),
    );
  }

  Future<Map<String, dynamic>> closeCourse(int id) async {
    final result = await _client.patch('/api/v1/iam/courses/$id/close');
    return result.fold(
      (e) => throw Exception(e.message),
      (data) => Map<String, dynamic>.from(data as Map? ?? {}),
    );
  }

  Future<Map<String, dynamic>> enrollStudents({
    required int courseId,
    required List<int> studentIds,
  }) async {
    final result = await _client.post(
      '/api/v1/iam/courses/$courseId/students',
      data: {'studentIds': studentIds},
    );
    return result.fold(
      (e) => throw Exception(e.message),
      (data) => Map<String, dynamic>.from(data as Map? ?? {}),
    );
  }

  // ── Grupos ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createGroup({
    required String name,
    required int courseId,
  }) async {
    final result = await _client.post(
      '/api/v1/iam/groups',
      data: {'name': name, 'courseId': courseId},
    );
    return result.fold(
      (e) => throw Exception(e.message),
      (data) => Map<String, dynamic>.from(data as Map),
    );
  }

  Future<Map<String, dynamic>> getGroup(int id) async {
    final result = await _client.get('/api/v1/iam/groups/$id');
    return result.fold(
      (e) => throw Exception(e.message),
      (data) => Map<String, dynamic>.from(data as Map),
    );
  }

  Future<Map<String, dynamic>> addGroupMembers({
    required int groupId,
    required List<int> memberIds,
  }) async {
    final result = await _client.post(
      '/api/v1/iam/groups/$groupId/members',
      data: {'memberIds': memberIds},
    );
    return result.fold(
      (e) => throw Exception(e.message),
      (data) => Map<String, dynamic>.from(data as Map? ?? {}),
    );
  }

  Future<void> removeGroupMember({
    required int groupId,
    required int studentId,
  }) async {
    final result =
        await _client.delete('/api/v1/iam/groups/$groupId/members/$studentId');
    result.fold(
      (e) => throw Exception(e.message),
      (_) => null,
    );
  }

  Future<Map<String, dynamic>> linkGroupCompany({
    required int groupId,
    required int companyId,
  }) async {
    final result = await _client.patch(
      '/api/v1/iam/groups/$groupId/company',
      data: {'companyId': companyId},
    );
    return result.fold(
      (e) => throw Exception(e.message),
      (data) => Map<String, dynamic>.from(data as Map? ?? {}),
    );
  }

  // ── Usuarios ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getUser(int id) async {
    final result = await _client.get('/api/v1/iam/users/$id');
    return result.fold(
      (e) => throw Exception(e.message),
      (data) => Map<String, dynamic>.from(data as Map),
    );
  }

  Future<Map<String, dynamic>> updateUserRoles({
    required int userId,
    required List<int> roleIds,
  }) async {
    final result = await _client.put(
      '/api/v1/iam/users/$userId/roles',
      data: {'roleIds': roleIds},
    );
    return result.fold(
      (e) => throw Exception(e.message),
      (data) => Map<String, dynamic>.from(data as Map? ?? {}),
    );
  }
}

final academicDataSourceProvider = Provider<AcademicRemoteDataSource>((ref) {
  return AcademicRemoteDataSource(ref.watch(iamApiClientProvider));
});
