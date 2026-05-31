# Implementation Plan: Release Build Preparation

## Overview

Prepare and generate a signed Android App Bundle (AAB) for Mindfulness Garden `1.0.7+8`, ready for upload to Google Play Console. The plan covers the `.env` asset security fix, version bump, pre-build environment checks, the release build itself, post-build verification, and property-based tests for the version-parsing logic.

## Tasks

- [x] 1. Fix `.env` asset security issue in `pubspec.yaml`
  - Remove the `- .env` line from the `flutter.assets` list in `pubspec.yaml`
  - Remove the `flutter_dotenv: ^6.0.0` entry from `dependencies` in `pubspec.yaml` (the package is declared but never called in Dart code — no runtime changes needed)
  - Verify no Dart file imports `package:flutter_dotenv/flutter_dotenv.dart` or calls `dotenv.load()` (confirmed: none exist)
  - _Requirements: 4.2 (ProGuard/asset hygiene), design §5 (Asset Security)_

- [x] 2. Bump version in `pubspec.yaml` from `1.0.6+7` to `1.0.7+8`
  - Edit line 4 of `pubspec.yaml`: change `version: 1.0.6+7` to `version: 1.0.7+8`
  - No changes needed in `android/app/build.gradle.kts` — it reads `flutter.versionCode` and `flutter.versionName` automatically
  - _Requirements: 3.1, 3.2, 3.4_

- [x] 3. Write version-parsing utility and property-based tests
  - [x] 3.1 Create `lib/core/utils/version_parser.dart`
    - Implement `FlutterVersion parseFlutterVersion(String versionString)` that splits on `+` and returns a record/class with `versionName` (String) and `versionCode` (int)
    - Throw `FormatException` for malformed input (missing `+`, non-integer build number, non-semver name)
    - _Requirements: 3.1, 3.4_

  - [x]* 3.2 Write property test — Property 1: Version string round-trip
    - Create `test/core/utils/version_parser_test.dart`
    - Add `glados` to `dev_dependencies` in `pubspec.yaml` (or use `dart_test` with manual generators)
    - **Property 1: Version String Round-Trip** — for any `MAJOR.MINOR.PATCH+N`, `parseFlutterVersion` returns `versionName == "MAJOR.MINOR.PATCH"` and `versionCode == N`
    - Run minimum 100 iterations
    - Tag: `// Feature: release-build-preparation, Property 1: Version string round-trip`
    - **Validates: Requirements 3.1, 5.3**

  - [x]* 3.3 Write property test — Property 2: Version code monotonicity
    - **Property 2: Version Code Monotonicity** — for any two build numbers `N < M`, `parseFlutterVersion("1.0.0+$M").versionCode > parseFlutterVersion("1.0.0+$N").versionCode`
    - Tag: `// Feature: release-build-preparation, Property 2: Version code monotonicity`
    - **Validates: Requirements 3.2**

  - [x]* 3.4 Write property test — Property 3: Version name semver compliance
    - **Property 3: Version Name Semver Compliance** — for any non-negative `MAJOR.MINOR.PATCH`, `parseFlutterVersion` returns a `versionName` matching `^\d+\.\d+\.\d+$`
    - Tag: `// Feature: release-build-preparation, Property 3: Version name semver compliance`
    - **Validates: Requirements 3.4**

  - [x]* 3.5 Write property test — Property 4: Build configuration fidelity (minSdk)
    - **Property 4: Build Configuration Fidelity** — parse `android/app/build.gradle.kts` and assert `minSdk = 26` is present; this is a static-analysis test that reads the file and checks the declared value
    - Tag: `// Feature: release-build-preparation, Property 4: Build configuration fidelity`
    - **Validates: Requirements 6.3**

- [x] 4. Checkpoint — run unit and property tests
  - Run `flutter test test/core/utils/version_parser_test.dart`
  - Ensure all tests pass; ask the user if any failures arise before proceeding to the build steps.

- [x] 5. Pre-build environment checks (shell commands — run manually)
  - Run `flutter doctor -v` and confirm `[✓] Android toolchain` with no errors
    - If license errors appear, run `flutter doctor --android-licenses` and accept all with `y`
  - Run `flutter pub get` and confirm exit code 0 with no dependency conflicts
  - Verify `android/key.properties` has all four fields populated: `storeFile`, `storePassword`, `keyAlias`, `keyPassword`
  - Verify `C:\Users\Sourav\upload-keystore.jks` exists on disk
  - _Requirements: 1.1, 1.2, 2.1, 2.2, 2.4_

- [x] 6. Generate the signed release AAB (shell command — run manually)
  - Run `flutter build appbundle --release` from the project root
  - Expected output: `✓ Built build\app\outputs\bundle\release\app-release.aab`
  - If the build fails with a ProGuard/R8 error, add the flagged class to `android/app/proguard-rules.pro` with the appropriate `-keep` or `-dontwarn` rule and rebuild
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [ ] 7. Post-build verification (shell commands — run manually)
  - [ ] 7.1 Verify AAB signing with `jarsigner`
    - Run: `jarsigner -verify -verbose -certs build\app\outputs\bundle\release\app-release.aab`
    - Expected: output contains `jar verified.`
    - _Requirements: 1.5, 5.2_

  - [ ] 7.2 Validate AAB structure with `bundletool`
    - Run: `java -jar bundletool.jar validate --bundle=build\app\outputs\bundle\release\app-release.aab`
    - Expected: no errors
    - Download `bundletool.jar` from https://github.com/google/bundletool/releases if not already present
    - _Requirements: 5.1_

  - [ ] 7.3 Verify manifest version code and name with `aapt2`
    - Extract a universal APK and run: `aapt2 dump badging universal.apk | Select-String "versionCode|versionName|minSdk"`
    - Expected: `versionCode='8'`, `versionName='1.0.7'`, `sdkVersion:'26'`
    - _Requirements: 5.3, 6.2, 6.3_

  - [ ] 7.4 Verify ABI coverage with `bundletool`
    - Run `bundletool build-apks --mode=default` and list generated APKs
    - Expected: APKs present for `arm64-v8a` and `x86_64`
    - _Requirements: 5.4_

- [ ] 8. Final checkpoint — confirm build artifacts are valid
  - All verification steps in task 7 must pass before proceeding to Play Console upload.
  - Ensure all tests pass; ask the user if any issues arise.

- [ ]* 9. Upload to Google Play Console — Internal Testing (manual, optional)
  - Navigate to Play Console → Mindfulness Garden → Testing → Internal testing
  - Click **Create new release**, upload `build\app\outputs\bundle\release\app-release.aab`
  - Confirm Play Console displays `versionCode = 8` and `versionName = 1.0.7`
  - Click **Save → Review release → Start rollout to Internal testing**
  - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [ ]* 10. Set up Closed Testing track and add testers (manual, optional)
  - Navigate to Play Console → Testing → Closed testing
  - Create or use the default Alpha track; add 12+ tester Google accounts (or a Google Group)
  - Promote the Internal Testing release to Closed Testing (or create a new release on the track)
  - Confirm opt-in invitation emails are sent to all testers
  - Record the date the track is first published — the 14-day timer starts here
  - _Requirements: 7.1, 7.2, 7.3, 7.4_

- [ ]* 11. Monitor Closed Testing prerequisites (manual, optional)
  - Check Play Console checklist: opted-in tester count (≥ 12) and days active (≥ 14)
  - Upload updated AABs with incremented version codes as needed — this does not reset the 14-day timer
  - Once both prerequisites are green, click **Apply for production access** and complete the application form
  - _Requirements: 7.5, 8.1, 8.2, 8.3, 8.4, 8.5_

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP or deferred to a later session
- Tasks 5, 6, and 7 involve running shell commands — they cannot be executed by a coding agent and must be run manually in a terminal
- Tasks 9–11 are Play Console web UI steps that cannot be automated
- Property tests (3.2–3.5) validate the version-parsing logic independently of the build environment
- The `glados` package is the recommended property-testing library for Dart; if unavailable, implement a simple generator loop using `dart:math` Random
