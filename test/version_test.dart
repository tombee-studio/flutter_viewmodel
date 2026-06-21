import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_viewmodel/flutter_viewmodel.dart';

void main() {
  group('version', () {
    test('exposes a non-empty version string at the library top level', () {
      expect(version, isNotEmpty);
    });

    test('follows semantic versioning format', () {
      final semverRegExp = RegExp(
        r'^\d+\.\d+\.\d+(?:[-+].+)?$',
      );
      expect(
        semverRegExp.hasMatch(version),
        isTrue,
        reason: 'version "$version" is not a valid semantic version',
      );
    });

    test('matches the version declared in pubspec.yaml', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final match = RegExp(
        r'^version:\s*(.+)$',
        multiLine: true,
      ).firstMatch(pubspec);

      expect(
        match,
        isNotNull,
        reason: 'Could not find a "version:" entry in pubspec.yaml',
      );

      final pubspecVersion = match!.group(1)!.trim();
      expect(
        version,
        pubspecVersion,
        reason:
            'The code version ("$version") must match pubspec.yaml ("$pubspecVersion")',
      );
    });
  });
}
