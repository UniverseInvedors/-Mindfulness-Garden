# Fastlane Configuration for PranaVerse: Healing Frequencies

## Setup Instructions

### 1. Install Fastlane
```bash
# Using RubyGems
sudo gem install fastlane -NV

# Or using Homebrew (macOS)
brew install fastlane
```

### 2. Initialize Fastlane
```bash
cd fastlane
fastlane init
```

### 3. Set up Google Play Service Account
1. Go to Google Play Console
2. Navigate to Setup → API Access
3. Create a new service account
4. Download the JSON key file
5. Save it as `fastlane/service-account.json`
6. **IMPORTANT**: Never commit this file to version control

### 4. Configure Environment Variables
Create a `.env` file in the fastlane directory:
```
FASTLANE_SKIP_UPDATE_CHECK=true
```

## Available Lanes

### Build Lanes
- `fastlane build_aab` - Build Android App Bundle only
- `fastlane release` - Complete release workflow (clean, test, analyze, build)

### Deployment Lanes
- `fastlane internal` - Build and upload to Internal Testing track
- `fastlane closed_beta` - Build and upload to Closed Testing track
- `fastlane open_beta` - Build and upload to Open Testing track
- `fastlane production` - Build and upload to Production track

### Utility Lanes
- `fastlane test` - Run Flutter tests
- `fastlane analyze` - Run Flutter analyze
- `fastlane clean` - Clean build artifacts
- `fastlane bump_version` - Increment version number

### Metadata Lanes
- `fastlane upload_metadata` - Upload store listing metadata
- `fastlane upload_screenshots` - Upload screenshots to Play Store
- `fastlane sync_screenshots` - Sync screenshots to all language folders

## Usage Examples

### Build for Internal Testing
```bash
fastlane internal
```

### Build for Production
```bash
fastlane production
```

### Complete Release Workflow
```bash
fastlane release
```

### Bump Version and Build
```bash
fastlane bump_version
fastlane production
```

## Release Workflow

### For Beta Release
1. Run `fastlane closed_beta`
2. Monitor feedback in Google Play Console
3. Address issues
4. Repeat until stable

### For Production Release
1. Ensure all tests pass: `fastlane test`
2. Run code analysis: `fastlane analyze`
3. Complete release workflow: `fastlane release`
4. Upload to production: `fastlane production`
5. Monitor rollout in Google Play Console
6. Increase rollout gradually if stable

## Troubleshooting

### Authentication Issues
If you encounter authentication errors:
- Verify service account JSON is correct
- Ensure service account has proper permissions
- Check that package name matches Appfile

### Build Failures
If build fails:
- Run `flutter clean` then `flutter pub get`
- Check Android SDK version compatibility
- Verify signing configuration

### Upload Failures
If upload to Play Store fails:
- Check internet connection
- Verify Google Play Console API access
- Ensure track name is correct

## Security Notes

- **Never commit** `service-account.json` to version control
- **Never commit** `key.properties` to version control
- **Never commit** any keystore files
- Use environment variables for sensitive data
- Rotate service account keys regularly

## CI/CD Integration

Fastlane can be integrated with GitHub Actions. See `.github/workflows/android-release.yml` for the automated workflow.

## Additional Resources

- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Google Play Developer API](https://developers.google.com/android-publisher)
- [Flutter Build Documentation](https://flutter.dev/docs/deployment/android)
