import 'dart:io';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:pranaverse/core/utils/version_parser.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Unit tests — deterministic cases
  // ---------------------------------------------------------------------------

  group('parseFlutterVersion — unit tests', () {
    test('parses current app version 1.0.7+8 correctly', () {
      final v = parseFlutterVersion('1.0.7+8');
      expect(v.versionName, equals('1.0.7'));
      expect(v.versionCode, equals(8));
    });

    test('parses 0.0.0+0 (minimum valid version)', () {
      final v = parseFlutterVersion('0.0.0+0');
      expect(v.versionName, equals('0.0.0'));
      expect(v.versionCode, equals(0));
    });

    test('parses large version numbers', () {
      final v = parseFlutterVersion('99.100.200+9999');
      expect(v.versionName, equals('99.100.200'));
      expect(v.versionCode, equals(9999));
    });

    test('throws FormatException for missing + separator', () {
      expect(() => parseFlutterVersion('1.0.7'), throwsFormatException);
    });

    test('throws FormatException for multiple + separators', () {
      expect(() => parseFlutterVersion('1.0.7+8+9'), throwsFormatException);
    });

    test('throws FormatException for non-integer build number', () {
      expect(() => parseFlutterVersion('1.0.7+abc'), throwsFormatException);
    });

    test('throws FormatException for non-semver version name (two parts)', () {
      expect(() => parseFlutterVersion('1.0+8'), throwsFormatException);
    });

    test('throws FormatException for non-semver version name (four parts)', () {
      expect(() => parseFlutterVersion('1.0.7.1+8'), throwsFormatException);
    });

    test('throws FormatException for empty string', () {
      expect(() => parseFlutterVersion(''), throwsFormatException);
    });

    test('FlutterVersion equality works correctly', () {
      final v1 = parseFlutterVersion('1.0.7+8');
      final v2 = parseFlutterVersion('1.0.7+8');
      expect(v1, equals(v2));
    });

    test('FlutterVersion toString round-trips correctly', () {
      final v = parseFlutterVersion('1.0.7+8');
      expect(v.toString(), equals('1.0.7+8'));
    });
  });

  // ---------------------------------------------------------------------------
  // Property-based tests — generative
  // ---------------------------------------------------------------------------

  group('Property-based tests', () {
    const iterations = 100;
    final rng = Random(42); // fixed seed for reproducibility

    // Helper: generate a random non-negative int in [0, max)
    int randInt(int max) => rng.nextInt(max);

    // -------------------------------------------------------------------------
    // Feature: release-build-preparation, Property 1: Version string round-trip
    //
    // For any valid MAJOR.MINOR.PATCH+N version string, parseFlutterVersion
    // returns versionName == "MAJOR.MINOR.PATCH" and versionCode == N.
    // Validates: Requirements 3.1, 5.3
    // -------------------------------------------------------------------------
    test('Property 1: Version string round-trip', () {
      for (var i = 0; i < iterations; i++) {
        final major = randInt(100);
        final minor = randInt(100);
        final patch = randInt(100);
        final buildNumber = randInt(10000);

        final versionString = '$major.$minor.$patch+$buildNumber';
        final parsed = parseFlutterVersion(versionString);

        expect(
          parsed.versionName,
          equals('$major.$minor.$patch'),
          reason: 'versionName mismatch for input "$versionString"',
        );
        expect(
          parsed.versionCode,
          equals(buildNumber),
          reason: 'versionCode mismatch for input "$versionString"',
        );
      }
    });

    // -------------------------------------------------------------------------
    // Feature: release-build-preparation, Property 2: Version code monotonicity
    //
    // For any two build numbers N < M, versionCode derived from M is strictly
    // greater than versionCode derived from N.
    // Validates: Requirements 3.2
    // -------------------------------------------------------------------------
    test('Property 2: Version code monotonicity', () {
      for (var i = 0; i < iterations; i++) {
        final n = randInt(9999);
        final delta = randInt(1000) + 1; // delta >= 1, so m > n always
        final m = n + delta;

        final v1 = parseFlutterVersion('1.0.0+$n');
        final v2 = parseFlutterVersion('1.0.0+$m');

        expect(
          v2.versionCode,
          greaterThan(v1.versionCode),
          reason: 'Expected versionCode($m) > versionCode($n)',
        );
      }
    });

    // -------------------------------------------------------------------------
    // Feature: release-build-preparation, Property 3: Version name semver compliance
    //
    // For any non-negative MAJOR.MINOR.PATCH, the parsed versionName always
    // matches the pattern ^\d+\.\d+\.\d+$
    // Validates: Requirements 3.4
    // -------------------------------------------------------------------------
    test('Property 3: Version name semver compliance', () {
      final semverPattern = RegExp(r'^\d+\.\d+\.\d+$');

      for (var i = 0; i < iterations; i++) {
        final major = randInt(100);
        final minor = randInt(100);
        final patch = randInt(100);

        final versionString = '$major.$minor.$patch+1';
        final parsed = parseFlutterVersion(versionString);

        expect(
          semverPattern.hasMatch(parsed.versionName),
          isTrue,
          reason:
              'versionName "${parsed.versionName}" does not match semver pattern',
        );
      }
    });

    // -------------------------------------------------------------------------
    // Feature: release-build-preparation, Property 4: Build configuration fidelity
    //
    // The minSdk declared in android/app/build.gradle.kts is always 26,
    // ensuring the app is never accidentally published with a different minimum
    // SDK requirement.
    // Validates: Requirements 6.3
    // -------------------------------------------------------------------------
    test('Property 4: Build configuration fidelity — minSdk = 26', () {
      final buildGradle = File('android/app/build.gradle.kts');
      expect(
        buildGradle.existsSync(),
        isTrue,
        reason: 'android/app/build.gradle.kts not found',
      );

      final content = buildGradle.readAsStringSync();

      // Check minSdk is set to 26
      expect(
        content,
        contains('minSdk = 26'),
        reason: 'minSdk = 26 not found in build.gradle.kts',
      );

      // Check compileSdk is set to 36
      expect(
        content,
        contains('compileSdk = 36'),
        reason: 'compileSdk = 36 not found in build.gradle.kts',
      );

      // Check ProGuard minification is enabled
      expect(
        content,
        contains('isMinifyEnabled = true'),
        reason: 'isMinifyEnabled = true not found in build.gradle.kts',
      );

      // Check resource shrinking is enabled
      expect(
        content,
        contains('isShrinkResources = true'),
        reason: 'isShrinkResources = true not found in build.gradle.kts',
      );
    });
  });
}
