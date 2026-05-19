import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:core_sim_ia/core/storage/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return SecureTokenStorage();
});