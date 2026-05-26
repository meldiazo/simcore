import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simcore_frontend/core/storage/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return SecureTokenStorage();
});
