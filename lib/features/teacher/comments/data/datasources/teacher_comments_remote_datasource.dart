import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';

class TeacherCommentsRemoteDataSource {
  const TeacherCommentsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> getComments({
    required int companyId,
    required String module,
  }) async {
    final result = await _client.get(
      '/api/v1/simulation/companies/$companyId/comments',
      queryParameters: {'module': module},
    );
    return result.fold(
      (e) => throw Exception(e.message),
      (data) {
        final list = data as List? ?? [];
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      },
    );
  }

  Future<Map<String, dynamic>> addComment({
    required int companyId,
    required String module,
    required String content,
    required String visibility,
  }) async {
    final result = await _client.post(
      '/api/v1/simulation/companies/$companyId/comments',
      data: {'module': module, 'content': content, 'visibility': visibility},
    );
    return result.fold(
      (e) => throw Exception(e.message),
      (data) => Map<String, dynamic>.from(data as Map),
    );
  }

  Future<Map<String, dynamic>> updateComment({
    required int companyId,
    required int commentId,
    required String content,
    required String visibility,
  }) async {
    final result = await _client.put(
      '/api/v1/simulation/companies/$companyId/comments/$commentId',
      data: {'content': content, 'visibility': visibility},
    );
    return result.fold(
      (e) => throw Exception(e.message),
      (data) => Map<String, dynamic>.from(data as Map),
    );
  }

  Future<void> deleteComment({
    required int companyId,
    required int commentId,
  }) async {
    final result = await _client.delete(
        '/api/v1/simulation/companies/$companyId/comments/$commentId');
    result.fold(
      (e) => throw Exception(e.message),
      (_) => null,
    );
  }
}

final teacherCommentsDataSourceProvider =
    Provider<TeacherCommentsRemoteDataSource>((ref) {
  return TeacherCommentsRemoteDataSource(
      ref.watch(simulationApiClientProvider));
});
