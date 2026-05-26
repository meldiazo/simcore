import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('StratovaRemoteDataSource no debe depender del mock explícito', () {
    final file = File(
      'lib/features/stratova/data/datasources/stratova_remote_data_source.dart',
    );

    final content = file.readAsStringSync();

    expect(content, isNot(contains('StratovaMockDataSource')));
    expect(content, isNot(contains('_fallback')));
  });

  test('AppConfig debe usar configuración por dart-define', () {
    final file = File('lib/core/config/app_config.dart');
    final content = file.readAsStringSync();

    expect(content, contains('AppConfig.fromEnvironment()'));
    expect(content, contains('APP_ENV'));
    expect(content, contains('USE_MOCK_DATA'));
    expect(content, contains("defaultValue: 'local'"));
  });
}