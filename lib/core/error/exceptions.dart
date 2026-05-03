class ServerException implements Exception {
  const ServerException([this.message = 'Unable to fetch users']);

  final String message;

  @override
  String toString() => message;
}
