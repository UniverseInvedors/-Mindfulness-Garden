# Requirements Document

## Introduction

This feature covers the end-to-end process of preparing and generating a production-ready Android App Bundle (AAB) for the Mindfulness Garden app (`com.mindfulgarden.mindfulness_garden`, version `1.0.6+7`) suitable for upload to Google Play Console. The scope includes verifying and hardening the signing configuration, validating the build environment, generating the signed AAB, and satisfying Google Play's closed testing track prerequisites (minimum 12 testers, minimum 14 days) before applying for production access.

## Glossary

- **AAB**: Android App Bundle — the `.aab` file format required by Google Play for new app submissions.
- **Build_Tool**: The Flutter CLI (`flutter build appbundle`) used to compile and package the release AAB.
- **Keystore**: The Java KeyStore file (`upload-keystore.jks`) containing the upload key used to sign the AAB.
- **Key_Properties**: The `android/key.properties` file that supplies keystore credentials to the Gradle build.
- **Signing_Config**: The `release` signing configuration block in `android/app/build.gradle.kts`.
- **ProGuard**: The code-shrinking and obfuscation tool configured via `proguard-rules.pro`.
- **Play_Console**: Google Play Console — the web portal used to manage app releases.
- **Closed_Testing_Track**: A Google Play release track (internal/closed alpha) used to distribute the app to a defined set of testers before production.
- **Tester**: A Google account holder added to the closed testing track who can install and test the app.
- **Version_Code**: The integer build number (`versionCode`) used by Google Play to distinguish releases; must increment with each upload.
- **Version_Name**: The human-readable version string (`versionName`) displayed to users.

---

## Requirements

### Requirement 1: Keystore and Signing Configuration Validity

**User Story:** As a developer, I want the keystore file and signing credentials to be correctly configured, so that the release AAB is signed with the upload key accepted by Google Play Console.

#### Acceptance Criteria

1. THE Key_Properties file SHALL contain non-empty values for `storeFile`, `storePassword`, `keyAlias`, and `keyPassword`.
2. WHEN the build is initiated, THE Signing_Config SHALL resolve the `storeFile` path to an existing file on the build machine.
3. IF the `storeFile` path in Key_Properties is an absolute Windows path and the build runs on a non-Windows machine, THEN THE Build_Tool SHALL fail with a descriptive error indicating the path is not found, rather than silently producing an unsigned build.
4. THE Signing_Config SHALL use the `release` signing config for the `release` build type in `build.gradle.kts`.
5. WHEN the signed AAB is produced, THE Build_Tool SHALL embed a valid signature verifiable with `jarsigner -verify`.

---

### Requirement 2: Build Environment Verification

**User Story:** As a developer, I want the build environment to be verified before generating the release AAB, so that the build does not fail partway through due to missing tools or misconfiguration.

#### Acceptance Criteria

1. WHEN the developer runs the pre-build checklist, THE Build_Tool SHALL confirm that Flutter SDK, Android SDK, and Java 17 are available on the PATH.
2. WHEN the developer runs `flutter doctor`, THE Build_Tool SHALL report no errors relevant to Android toolchain (Android SDK, licenses, build tools).
3. THE Build_Tool SHALL confirm that `compileSdk = 36`, `minSdk = 26`, and `targetSdk` match the values declared in `android/app/build.gradle.kts` before building.
4. WHEN the developer runs `flutter pub get`, THE Build_Tool SHALL resolve all dependencies declared in `pubspec.yaml` without conflicts.
5. IF any dependency in `pubspec.yaml` cannot be resolved, THEN THE Build_Tool SHALL report the unresolved dependency name and version constraint before the build proceeds.

---

### Requirement 3: Version Code and Version Name Management

**User Story:** As a developer, I want the version code and version name to be correctly set before each upload, so that Google Play Console accepts the new AAB and users see the correct version.

#### Acceptance Criteria

1. THE Build_Tool SHALL derive `versionCode` and `versionName` from the `version` field in `pubspec.yaml` using the format `major.minor.patch+buildNumber`.
2. WHEN a new AAB is uploaded to Play Console, THE Version_Code of the new AAB SHALL be strictly greater than the Version_Code of any previously uploaded AAB on the same track.
3. IF the developer attempts to upload an AAB with a Version_Code equal to or less than an existing upload, THEN THE Play_Console SHALL reject the upload with an error message.
4. THE Version_Name SHALL follow semantic versioning (`MAJOR.MINOR.PATCH`) and SHALL be updated in `pubspec.yaml` before generating a release AAB intended for a new user-visible release.

---

### Requirement 4: Release AAB Generation

**User Story:** As a developer, I want to generate a signed release AAB using the Flutter build tool, so that I have a file ready to upload to Google Play Console.

#### Acceptance Criteria

1. WHEN the developer runs `flutter build appbundle --release`, THE Build_Tool SHALL produce a signed `.aab` file at `build/app/outputs/bundle/release/app-release.aab`.
2. THE Build_Tool SHALL apply ProGuard minification and resource shrinking during the release build, as configured by `isMinifyEnabled = true` and `isShrinkResources = true` in `build.gradle.kts`.
3. WHEN ProGuard processes the release build, THE Build_Tool SHALL apply all rules in `android/app/proguard-rules.pro` and SHALL NOT strip classes required by Flutter, Firebase, RevenueCat, Google Mobile Ads, or Hive.
4. WHEN the release build completes, THE Build_Tool SHALL report the total build time and the output file size of the AAB.
5. IF the release build fails due to a ProGuard rule conflict or missing class, THEN THE Build_Tool SHALL output the specific class name and rule that caused the failure.

---

### Requirement 5: AAB Integrity Verification

**User Story:** As a developer, I want to verify the generated AAB before uploading it, so that I can catch signing or packaging issues before they reach Google Play.

#### Acceptance Criteria

1. WHEN the AAB is generated, THE Build_Tool SHALL produce an AAB that passes `bundletool validate --bundle=app-release.aab` without errors.
2. WHEN the developer runs `jarsigner -verify -verbose -certs app-release.aab`, THE Build_Tool output SHALL confirm the AAB is signed and the certificate matches the upload keystore.
3. THE Build_Tool SHALL produce an AAB whose `versionCode` and `versionName` embedded in the manifest match the values declared in `pubspec.yaml`.
4. WHEN the developer uses `bundletool build-apks` to extract APKs from the AAB, THE Build_Tool output SHALL produce installable APKs for at least `arm64-v8a` and `x86_64` ABIs.

---

### Requirement 6: Google Play Console Upload

**User Story:** As a developer, I want to upload the signed AAB to Google Play Console, so that it is available for distribution on the closed testing track.

#### Acceptance Criteria

1. WHEN the developer uploads the AAB to Play Console, THE Play_Console SHALL accept the AAB without a signing mismatch error, confirming the upload key matches the registered key.
2. WHEN the AAB is processed by Play Console, THE Play_Console SHALL display the correct `versionCode` and `versionName` on the release details page.
3. THE Play_Console SHALL confirm that the AAB targets `minSdk = 26` and is compatible with devices running Android 8.0 and above.
4. WHEN the AAB upload is complete, THE Play_Console SHALL make the release available for promotion to the closed testing track within 60 minutes of upload.

---

### Requirement 7: Closed Testing Track Setup

**User Story:** As a developer, I want to set up a closed testing track with at least 12 testers, so that I can satisfy Google Play's prerequisite for applying for production access.

#### Acceptance Criteria

1. THE Play_Console SHALL allow the developer to create a closed testing track and add a minimum of 12 tester Google accounts before the release is published to that track.
2. WHEN the closed testing track is published, THE Play_Console SHALL send opt-in invitation emails to all 12 or more registered testers.
3. WHEN a tester accepts the opt-in invitation, THE Play_Console SHALL make the app installable from the Google Play Store for that tester's account within 24 hours.
4. THE Play_Console SHALL record the date the closed testing track was first published, and the developer SHALL maintain the track active for a minimum of 14 consecutive days before applying for production access.
5. WHILE the closed testing track is active, THE Play_Console SHALL allow the developer to upload updated AABs with incremented Version_Codes to the same track without resetting the 14-day timer.

---

### Requirement 8: Production Access Application Readiness

**User Story:** As a developer, I want to confirm all prerequisites are met before applying for production access, so that the application is not rejected due to incomplete testing requirements.

#### Acceptance Criteria

1. WHEN the developer applies for production access, THE Play_Console SHALL verify that the closed testing track has had at least 12 testers opted in for at least 14 consecutive days.
2. IF the closed testing track has fewer than 12 opted-in testers at the time of application, THEN THE Play_Console SHALL block the production access application and display the current tester count and the required minimum.
3. IF the closed testing track has been active for fewer than 14 days at the time of application, THEN THE Play_Console SHALL block the production access application and display the number of remaining days required.
4. WHEN all prerequisites are met, THE Play_Console SHALL enable the "Apply for production access" button and allow the developer to submit the application.
5. THE Play_Console SHALL provide a checklist view showing the status of each prerequisite (tester count, days active, policy compliance) so the developer can track progress toward production access.
