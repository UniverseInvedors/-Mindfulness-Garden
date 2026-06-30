# Setup Instructions for Auto Features

## Quick Start

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the App
```bash
flutter run
```

That's it! The auto features will initialize automatically.

## What Will Happen

When you launch the app:

1. **Location Permission**: The app will request location permission (first launch only)
2. **Auto-Detection**: Location, time, and season will be fetched automatically
3. **Dashboard**: You'll see your city/country and current time at the top
4. **Theme**: Theme will match time of day (dark at night, light during day)
5. **Background**: Dashboard background will match current season
6. **Garden**: Garden season will match current month automatically

## Testing the Features

### Test Auto Theme:
1. Open Settings → General
2. Enable "Auto Theme"  
3. Change device time to 8:00 PM → App switches to dark theme
4. Change device time to 10:00 AM → App switches to light theme

### Test Auto Background:
1. Open Settings → General
2. Enable "Auto Background"
3. Go to Dashboard → Background matches current season
4. Change device date to different season → Background updates

### Test Location Display:
1. Grant location permission
2. Open Dashboard
3. See location/time widget at top showing your city and current time
4. Wait 1 minute → Time updates automatically

### Test Garden Auto-Season:
1. Open Garden screen
2. Season matches current month automatically
3. Music plays for that season (already implemented)
4. You can still manually change seasons if desired

## Permissions Setup

### Android
Already configured in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS
Check `ios/Runner/Info.plist` includes:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to provide seasonal content and time-based features</string>
```

## API Usage (Free, No Keys Required)

- **WorldTimeAPI**: `http://worldtimeapi.org/api/ip` - Time/date/timezone
- **OpenStreetMap Nominatim**: Reverse geocoding for city/country names
- **Geolocator**: Device GPS for coordinates

All APIs are free and require no API keys.

## User Controls

Users can toggle these features in Settings → General:
- **Auto Theme**: Enable/disable automatic light/dark switching
- **Auto Background**: Enable/disable seasonal backgrounds

Both are enabled by default.

## Files Changed Summary

### New Files Created:
```
lib/core/services/location_time_service.dart
lib/core/services/auto_theme_service.dart
lib/features/dashboard/widgets/location_time_widget.dart
AUTO_FEATURES_IMPLEMENTATION.md (documentation)
SETUP_INSTRUCTIONS.md (this file)
```

### Files Modified:
```
lib/main.dart
lib/core/providers/app_settings_provider.dart
lib/features/dashboard/dashboard_screen.dart
lib/features/garden/garden_screen.dart
lib/features/settings/settings_screen.dart
```

## Troubleshooting

### "Location not detected"
- Ensure location services are enabled on device
- Check that location permission was granted
- Verify internet connection (for reverse geocoding)

### "Time not updating"
- Service falls back to device time automatically
- Check internet connection for WorldTimeAPI

### "Theme not changing automatically"
- Verify "Auto Theme" is ON in Settings → General
- Current time must trigger change (6 AM or 7 PM)

### "Build errors after pulling changes"
```bash
flutter clean
flutter pub get
flutter run
```

## Features Overview

✅ **Automatic time-based theme switching** (dark at night, light during day)  
✅ **Automatic seasonal backgrounds** (spring/summer/autumn/winter images)  
✅ **Location & time display** (city, country, current time on dashboard)  
✅ **Auto garden season** (matches current month automatically)  
✅ **User toggles** (can enable/disable all auto features)  
✅ **Privacy-friendly** (location stays on device)  
✅ **Free APIs** (no costs or API keys needed)  
✅ **Graceful fallbacks** (uses device time if APIs fail)

## Next Steps

1. Run `flutter pub get`
2. Launch the app
3. Grant location permission when prompted
4. Explore the dashboard to see location/time widget
5. Try Settings → General to toggle auto features
6. Visit Garden to see auto-season in action

Enjoy your enhanced, futuristic mindfulness app! 🌟🧘‍♀️✨
