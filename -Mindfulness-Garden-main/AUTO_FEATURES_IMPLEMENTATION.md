# Automatic Date/Time/Location Features Implementation

## Overview
This document describes the implementation of automatic date/time/location features with intelligent theme and background switching to make the app more attractive and futuristic.

## Features Implemented

### 1. **Location & Time Service** (`lib/core/services/location_time_service.dart`)
Automatically fetches and updates:
- **Current Date & Time**: Using WorldTimeAPI (free, no API key required)
- **User Location**: Using device GPS via Geolocator
- **City & Country**: Using OpenStreetMap Nominatim for reverse geocoding (free)
- **Auto-updates**: Refreshes every minute to keep data current

**APIs Used:**
- WorldTimeAPI: `http://worldtimeapi.org/api/ip` - Accurate time/timezone
- OpenStreetMap Nominatim: Reverse geocoding for location names
- Geolocator: Device GPS location

**Features:**
- Determines time of day (dawn/morning/afternoon/dusk/night)
- Calculates current season based on month
- Suggests dark/light theme based on time (dark: 7PM-6AM)
- Auto-refresh every minute

### 2. **Auto Theme Service** (`lib/core/services/auto_theme_service.dart`)
Intelligently manages:
- **Auto Theme Switching**: Dark theme at night (7PM-6AM), light during day
- **Auto Background Selection**: Season-based backgrounds (spring.jpeg, summer.jpeg, winter.jpeg, autumn.jpeg)
- **Auto Garden Season**: Automatically sets garden season based on current date
- **User Toggles**: Users can enable/disable auto features

**Season Mapping:**
- **Spring** (Mar-May): spring.jpeg
- **Summer** (Jun-Aug): summer.jpeg
- **Autumn** (Sep-Nov): autumn.jpeg  
- **Winter** (Dec-Feb): winter.jpeg
- **Monsoon** (Jun-Sep): monsoon season in garden
- **Night**: Always uses winter.jpeg for dark atmosphere

### 3. **Dashboard Location/Time Widget** (`lib/features/dashboard/widgets/location_time_widget.dart`)
Displays at top of dashboard:
- Current city and country
- Current time (updates every minute)
- Beautiful glass-morphic design
- Integrates seamlessly with existing UI

### 4. **Dashboard Background Integration**
- Auto-applies seasonal background images with 15% opacity
- Subtle and non-intrusive
- Enhances visual appeal without overwhelming content
- Can be toggled off in settings

### 5. **Garden Auto-Season**
- Garden season automatically matches current date
- Spring/Summer/Monsoon/Autumn/Winter/Snowfall
- Users can still manually change seasons for exploration
- Season changes affect:
  - Background music (already implemented)
  - Weather effects (rain, snow)
  - Plant growth rates
  - Visual environment

### 6. **Settings Integration**
Added two toggles in Settings > General:
- **Auto Theme**: Enable/disable automatic light/dark theme switching
- **Auto Background**: Enable/disable seasonal background changes

## Files Modified

### Created Files:
1. `lib/core/services/location_time_service.dart` - Location & time fetching
2. `lib/core/services/auto_theme_service.dart` - Theme & background automation
3. `lib/features/dashboard/widgets/location_time_widget.dart` - Dashboard widget

### Modified Files:
1. `lib/main.dart` - Initialize services at startup
2. `lib/core/providers/app_settings_provider.dart` - Integrate AutoThemeService
3. `lib/features/dashboard/dashboard_screen.dart` - Add location widget & auto background
4. `lib/features/garden/garden_screen.dart` - Auto-season initialization
5. `lib/features/settings/settings_screen.dart` - Add toggle switches

## How It Works

### App Startup Flow:
```
1. main.dart initializes LocationTimeService
2. main.dart initializes AutoThemeService
3. AutoThemeService listens to LocationTimeService
4. AppSettingsProvider listens to AutoThemeService
5. When time/location changes → theme/background updates automatically
```

### Time-Based Theme Switching:
```
Time          | Theme
--------------|-------
6 AM - 7 PM   | Light
7 PM - 6 AM   | Dark
```

### Season Detection:
```
Month         | Season    | Background    | Garden
--------------|-----------|---------------|-------------
Mar-May       | Spring    | spring.jpeg   | Spring
Jun-Aug       | Summer    | summer.jpeg   | Summer/Monsoon
Sep-Nov       | Autumn    | autumn.jpeg   | Autumn
Dec-Feb       | Winter    | winter.jpeg   | Winter/Snowfall
```

### Garden Music (Already Implemented):
```
Season        | Music File
--------------|-------------
Spring        | spring.mp3
Summer        | summer.mp3
Monsoon       | rainny.mp3
Autumn        | spring.mp3 (fallback)
Winter        | winter.mp3
```

## User Experience

### Automatic Features:
1. **Morning (6 AM)**: App switches to light theme automatically
2. **Evening (7 PM)**: App switches to dark theme automatically
3. **Season Change**: Background and garden season update automatically
4. **Location Display**: Shows current city/country and time on dashboard
5. **Background Music**: Garden plays season-appropriate music

### Manual Control:
Users can still:
- Manually toggle theme in settings (disables auto-theme)
- Manually change garden seasons (doesn't affect auto-detection)
- Enable/disable auto features via settings toggles

## Dependencies

All required dependencies are already in `pubspec.yaml`:
- `geolocator: ^12.0.0` - Device location
- `http: ^1.2.2` - API calls
- `intl: ^0.20.2` - Date formatting

## Permissions

### Android (`android/app/src/main/AndroidManifest.xml`):
Already includes:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS (`ios/Runner/Info.plist`):
Needs to include (likely already present):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to provide weather-based features and seasonal content</string>
```

## Benefits

### User Benefits:
- ✅ **No manual configuration**: Everything works automatically
- ✅ **Better readability**: Dark theme at night, light during day
- ✅ **Seasonal immersion**: Background and garden match real seasons
- ✅ **Location awareness**: See your city and accurate time
- ✅ **Futuristic feel**: App adapts to user's environment

### Technical Benefits:
- ✅ **Free APIs**: No API keys or costs required
- ✅ **Privacy-friendly**: Location data stays on device
- ✅ **Efficient**: Updates only once per minute
- ✅ **Fallback**: Uses device time if APIs fail
- ✅ **User control**: All features can be toggled

## Testing

### Test Scenarios:

1. **Time-based theme switching**:
   - Change device time to 8 PM → Should switch to dark theme
   - Change device time to 10 AM → Should switch to light theme

2. **Location display**:
   - Open dashboard → Should see city/country and time
   - Wait 1 minute → Time should update

3. **Seasonal backgrounds**:
   - Change device date to different seasons
   - Restart app → Background should match season

4. **Garden auto-season**:
   - Open garden screen
   - Season should match current month

5. **Settings toggles**:
   - Disable auto-theme → Theme should not auto-switch
   - Disable auto-background → Background should not change

## Future Enhancements

Possible improvements:
- Weather-based backgrounds (sunny/rainy/cloudy)
- Time-based meditation recommendations
- Location-based content (local holidays, festivals)
- Sunrise/sunset aware theme switching
- Seasonal achievement notifications

## Troubleshooting

### Location not detected:
- Check location permissions in device settings
- Ensure GPS/location services are enabled
- Check internet connection for reverse geocoding

### Time not updating:
- Check internet connection
- Service falls back to device time automatically

### Theme not auto-switching:
- Verify "Auto Theme" toggle is ON in settings
- Check that current time triggers theme change (7 PM / 6 AM)

## Summary

The implementation provides a seamless, automatic experience that makes the app feel more alive and connected to the user's real-world environment. All features are non-intrusive, respect user privacy, and can be disabled if desired.

The app now:
- Shows where you are and what time it is
- Adapts its appearance to day/night cycles
- Changes backgrounds and seasons automatically
- Provides a more immersive, futuristic experience
- Maintains all existing manual controls for power users
