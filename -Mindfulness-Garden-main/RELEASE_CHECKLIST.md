# PranaVerse: Healing Frequencies - Release Checklist

## Pre-Release Checklist

### Code Quality
- [ ] Remove all debug print statements and console logs
- [ ] Remove any test APIs or debug configurations
- [ ] Ensure all TODO comments are addressed or documented
- [ ] Run `flutter analyze` and fix all warnings
- [ ] Run `dart fix --apply` to apply automated fixes
- [ ] Test all critical user flows end-to-end
- [ ] Verify no hardcoded test data in production builds

### Build Configuration
- [ ] Verify package name: `com.universeinvedors.pranaverse`
- [ ] Verify app name: `PranaVerse: Healing Frequencies`
- [ ] Verify version: `1.0.0+1`
- [ ] Verify minSdk: 26
- [ ] Verify targetSdk: 36
- [ ] Verify signing configuration is correct
- [ ] Verify ProGuard rules are appropriate
- [ ] Verify resource shrinking is enabled

### Firebase Configuration
- [ ] Create new Firebase project for `com.universeinvedors.pranaverse`
- [ ] Add Android app in Firebase Console
- [ ] Download new `google-services.json`
- [ ] Re-enable Firebase plugins in `build.gradle.kts`
- [ ] Test Firebase Analytics
- [ ] Test Firebase Crashlytics
- [ ] Test Firebase Auth (if used)
- [ ] Test Firebase Cloud Messaging (if used)

### Google Play Console Setup
- [ ] Create new app in Google Play Console
- [ ] Complete app details (name, description, category)
- [ ] Upload store listing assets (icon, screenshots, feature graphic)
- [ ] Complete content rating questionnaire
- [ ] Provide privacy policy URL
- [ ] Complete data safety section
- [ ] Set up app signing (Google Managed App Signing)
- [ ] Upload upload keystore to Google Play Console
- [ ] Configure pricing and distribution
- [ ] Set up content rating for all regions

## Release Build Checklist

### Build Process
- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Run `flutter build appbundle --release`
- [ ] Verify AAB file is generated successfully
- [ ] Verify AAB file size is reasonable (~100MB)
- [ ] Test AAB installation on physical device
- [ ] Verify app launches correctly
- [ ] Verify all permissions are requested appropriately

### Signing Verification
- [ ] Verify AAB is signed with correct keystore
- [ ] Verify signing certificate fingerprint matches Google Play Console
- [ ] Test signed APK installation (if needed for testing)

## Testing Checklist

### Functional Testing
- [ ] Test yoga sessions
- [ ] Test all breathing exercises
- [ ] Test meditation journeys
- [ ] Test healing frequencies playback
- [ ] Test progress tracking
- [ ] Test mood tracking
- [ ] Test achievements system
- [ ] Test settings and preferences
- [ ] Test user authentication (if applicable)
- [ ] Test offline functionality

### UI/UX Testing
- [ ] Test on different screen sizes (phone, tablet)
- [ ] Test on different Android versions (API 26+)
- [ ] Test landscape and portrait orientations
- [ ] Test dark mode (if supported)
- [ ] Verify all text is readable
- [ ] Verify all icons are visible
- [ ] Test navigation between screens
- [ ] Test back button behavior

### Performance Testing
- [ ] Measure app startup time
- [ ] Test memory usage during sessions
- [ ] Test battery consumption
- [ ] Test audio playback performance
- [ ] Test 3D rendering performance
- [ ] Verify no memory leaks

### Network Testing
- [ ] Test with poor network connection
- [ ] Test offline mode
- [ ] Test network error handling
- [ ] Verify data sync functionality

## Google Play Submission Checklist

### Closed Testing Track
- [ ] Create closed testing track
- [ ] Add at least 12 testers
- [ ] Upload AAB to closed testing
- [ ] Wait 14 days for testing period
- [ ] Collect and address tester feedback
- [ ] Fix critical bugs found during testing

### Production Release
- [ ] Address all critical issues from testing
- [ ] Update version number if needed
- [ ] Build final release AAB
- [ ] Upload to production track
- [ ] Complete release notes
- [ ] Schedule release or publish immediately
- [ ] Monitor initial user feedback
- [ ] Monitor crash reports via Firebase Crashlytics

## Post-Release Checklist

### Monitoring
- [ ] Set up Firebase Crashlytics alerts
- [ ] Monitor app stability and crash-free users
- [ ] Monitor user ratings and reviews
- [ ] Monitor download statistics
- [ ] Monitor in-app analytics

### Support
- [ ] Prepare FAQ for common issues
- [ ] Set up support email or contact form
- [ ] Monitor and respond to user reviews
- [ ] Document known issues

### Next Release Planning
- [ ] Collect feature requests
- [ ] Prioritize bug fixes
- [ ] Plan next version features
- [ ] Update roadmap

## Important Notes

### Firebase Setup Required
Before final release, you must:
1. Create a new Firebase project at https://console.firebase.google.com/
2. Add an Android app with package name `com.universeinvedors.pranaverse`
3. Download the new `google-services.json` file
4. Place it in `android/app/` directory
5. Uncomment Firebase plugins in `android/app/build.gradle.kts`

### Google Play Signing
- Use Google Managed App Signing for security
- The upload keystore (`upload-keystore.jks`) is for uploading to Google Play
- Google will generate and manage the production signing key
- Keep the upload keystore secure and backed up

### Keystore Credentials
- Store keystore credentials in environment变量 for CI/CD
- Never commit `key.properties` to version control
- Keep backup of keystore file in secure location

### Version Management
- Follow semantic versioning (MAJOR.MINOR.PATCH)
- Increment version code for every release
- Update version name for user-facing changes
