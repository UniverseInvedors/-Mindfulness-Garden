/// Utility for parsing Flutter version strings from pubspec.yaml.
///
/// Flutter version strings use the format: `MAJOR.MINOR.PATCH+buildNumber`
/// where the part before `+` becomes the Android `versionName` and the
/// integer after `+` becomes the Android `versionCode`.
library;

/// Represents a parsed Flutter version with its Android equivalents.
class FlutterVersion {
  /// The human-readable version string (e.g. "1.0.7").
  /// Corresponds to Android `versionName`.
  final String versionName;

  /// The integer build number (e.g. 8).
  /// Corresponds to Android `versionCode`. Must be strictly greater than
  /// any previously uploaded version on the same Play Store track.
  final int versionCode;

  const FlutterVersion({
    required this.versionName,
    required this.versionCode,
  });

  @override
  String toString() => '$versionName+$versionCode';

  @override
  bool operator ==(Object other) =>
      other is FlutterVersion &&
      other.versionName == versionName &&
      other.versionCode == versionCode;

  @override
  int get hashCode => Object.hash(versionName, versionCode);
}

/// Parses a Flutter version string in the format `MAJOR.MINOR.PATCH+buildNumber`.
///
/// Returns a [FlutterVersion] with:
/// - [FlutterVersion.versionName] = the `MAJOR.MINOR.PATCH` portion
/// - [FlutterVersion.versionCode] = the `buildNumber` as an integer
///
/// Throws [FormatException] if:
/// - The string does not contain exactly one `+` separator
/// - The build number is not a valid positive integer
/// - The version name does not match `MAJOR.MINOR.PATCH` (three dot-separated integers)
///
/// Example:
/// ```dart
/// final v = parseFlutterVersion('1.0.7+8');
/// print(v.versionName); // "1.0.7"
/// print(v.versionCode); // 8
/// ```
FlutterVersion parseFlutterVersion(String versionString) {
  final parts = versionString.split('+');

  if (parts.length != 2) {
    throw FormatException(
      'Invalid Flutter version string: expected exactly one "+" separator, '
      'got "$versionString".',
    );
  }

  final versionName = parts[0];
  final buildNumberStr = parts[1];

  // Validate versionName is MAJOR.MINOR.PATCH
  final semverPattern = RegExp(r'^\d+\.\d+\.\d+$');
  if (!semverPattern.hasMatch(versionName)) {
    throw FormatException(
      'Invalid version name "$versionName": expected format MAJOR.MINOR.PATCH '
      '(e.g. "1.0.7").',
    );
  }

  // Validate and parse build number
  final versionCode = int.tryParse(buildNumberStr);
  if (versionCode == null) {
    throw FormatException(
      'Invalid build number "$buildNumberStr": expected a non-negative integer.',
    );
  }

  return FlutterVersion(
    versionName: versionName,
    versionCode: versionCode,
  );
}
