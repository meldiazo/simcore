import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('No deben quedar IDs heredados de módulos como strings productivos', () {
    final ignoredPathParts = <String>[
      '${Platform.pathSeparator}.git${Platform.pathSeparator}',
      '${Platform.pathSeparator}build${Platform.pathSeparator}',
      '${Platform.pathSeparator}.dart_tool${Platform.pathSeparator}',
      '${Platform.pathSeparator}ios${Platform.pathSeparator}Pods${Platform.pathSeparator}',
      '${Platform.pathSeparator}docs${Platform.pathSeparator}legacy${Platform.pathSeparator}',
    ];

    final ignoredFiles = <String>[
      'no_legacy_module_strings_test.dart',
    ];

    final targetExtensions = <String>{
      '.dart',
      '.yaml',
      '.yml',
      '.md',
      '.json',
    };

    final bannedPatterns = <RegExp>[
      RegExp(r"""['"]finance['"]"""),
      RegExp(r"""['"]hr['"]"""),
      RegExp(r"""['"]operations['"]"""),
      RegExp(r"""['"]market['"]"""),
      RegExp(r"""\/finance\b"""),
      RegExp(r"""\/hr\b"""),
      RegExp(r"""\/operations\b"""),
    ];

    final offenders = <String>[];

    for (final entity in Directory.current.listSync(recursive: true)) {
      if (entity is! File) continue;

      final path = entity.path;

      if (ignoredFiles.any(path.endsWith)) continue;
      if (ignoredPathParts.any(path.contains)) continue;
      if (!targetExtensions.any(path.endsWith)) continue;

      final content = entity.readAsStringSync();

      for (final pattern in bannedPatterns) {
        if (pattern.hasMatch(content)) {
          offenders.add('$path coincide con ${pattern.pattern}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Quedan strings heredados de módulos:\n${offenders.join('\n')}',
    );
  });
}