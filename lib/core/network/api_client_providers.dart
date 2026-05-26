import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:core_sim_ia/core/config/app_config.dart';
import 'package:core_sim_ia/core/network/api_client.dart';
import 'package:core_sim_ia/core/storage/token_storage.dart';
import 'package:core_sim_ia/core/storage/token_storage_provider.dart';

final sessionExpiredSignalProvider = StateProvider<int>((ref) => 0);

final publicIamApiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);

  return ApiClient(
    baseUrl: config.iamUrl,
  );
});

final iamApiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final storage = ref.watch(tokenStorageProvider);

  return ApiClient(
    baseUrl: config.iamUrl,
    tokenProvider: () => storage.getAccessToken(),
    onRefresh: () => _refreshAccessToken(ref),
    onSessionExpired: () => _expireSession(ref),
  );
});

final simulationApiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final storage = ref.watch(tokenStorageProvider);

  return ApiClient(
    baseUrl: config.simUrl,
    tokenProvider: () => storage.getAccessToken(),
    onRefresh: () => _refreshAccessToken(ref),
    onSessionExpired: () => _expireSession(ref),
  );
});

Future<String?> _refreshAccessToken(Ref ref) async {
  final storage = ref.read(tokenStorageProvider);
  final refreshToken = await storage.getRefreshToken();

  if (refreshToken == null || refreshToken.trim().isEmpty) {
    _expireSession(ref);
    return null;
  }

  final client = ref.read(publicIamApiClientProvider);

  final result = await client.post(
    '/api/v1/iam/auth/refresh',
    data: {
      'refreshToken': refreshToken,
    },
  );

  return result.fold(
    (failure) async {
      _expireSession(ref);
      return null;
    },
    (data) async {
      if (data is! Map) {
        _expireSession(ref);
        return null;
      }

      final json = Map<String, dynamic>.from(data);

      final accessToken = json['accessToken']?.toString();
      final newRefreshToken = (json['refreshToken'] ?? refreshToken).toString();

      if (accessToken == null || accessToken.trim().isEmpty) {
        _expireSession(ref);
        return null;
      }

      await storage.saveTokens(
        StoredTokens(
          accessToken: accessToken,
          refreshToken: newRefreshToken,
        ),
      );

      return accessToken;
    },
  );
}

void _expireSession(Ref ref) {
  unawaited(ref.read(tokenStorageProvider).clearTokens());
  ref.read(sessionExpiredSignalProvider.notifier).state++;
}