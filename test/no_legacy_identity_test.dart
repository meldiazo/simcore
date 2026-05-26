import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('No debe quedar identidad heredada Stratova en archivos productivos',
      () {
    final legacyTerms = <String>[
      'Stratova',
      'stratova',
      'STRATOVA',
    ];

    final ignoredPathParts = <String>[
      '${Platform.pathSeparator}.git${Platform.pathSeparator}',
      '${Platform.pathSeparator}build${Platform.pathSeparator}',
      '${Platform.pathSeparator}.dart_tool${Platform.pathSeparator}',
      '${Platform.pathSeparator}ios${Platform.pathSeparator}Pods${Platform.pathSeparator}',
    ];

    final allowedExtensions = <String>{
      '.dart',
      '.yaml',
      '.yml',
      '.md',
      '.html',
      '.json',
      '.xml',
      '.gradle',
      '.kt',
      '.swift',
      '.plist',
      '.rc',
      '.cpp',
    };

    final offenders = <String>[];

    for (final entity in Directory.current.listSync(recursive: true)) {
      if (entity is! File) continue;

      final path = entity.path;

      if (path.endsWith('no_legacy_identity_test.dart')) continue;

      final ignored = ignoredPathParts.any(path.contains);
      if (ignored) continue;

      final validExtension = allowedExtensions.any(path.endsWith);
      if (!validExtension) continue;

      final content = entity.readAsStringSync();

      for (final term in legacyTerms) {
        if (content.contains(term)) {
          offenders.add('$path contiene "$term"');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Quedan referencias heredadas:\n${offenders.join('\n')}',
    );
  });

  test('No deben quedar etiquetas de IA inflada sin lógica real', () {
    final suspiciousTerms = <String>[
      'xAI',
      'AI Analyst',
      'sandbox cuantico',
      'sandbox cuántico',
      'Montecarlo',
    ];

    final offenders = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final content = entity.readAsStringSync();

      for (final term in suspiciousTerms) {
        if (content.contains(term)) {
          offenders.add('${entity.path} contiene "$term"');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Quedan textos de IA no justificada:\n${offenders.join('\n')}',
    );
  });
}
