# Auto Features Architecture Diagram

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         APP STARTUP                             │
│                         (main.dart)                             │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ├──► LocationTimeService.initialize()
                     │    ├─ Request location permission
                     │    ├─ Get GPS coordinates (Geolocator)
                     │    ├─ Fetch city/country (OpenStreetMap)
                     │    └─ Fetch time/date (WorldTimeAPI)
                     │
                     └──► AutoThemeService.initialize()
                          ├─ Listen to LocationTimeService
                          ├─ Calculate time of day
                          ├─ Determine season
                          └─ Set up auto-theme/background
```

## Data Flow

```
┌──────────────────────┐
│  LocationTimeService │ (Core Service)
│  ────────────────────│
│  • GPS Location      │
│  • City/Country      │
│  • Current Time      │
│  • Current Date      │
│  • Timezone          │
│  • Time of Day       │
│  • Season            │
└──────────┬───────────┘
           │
           │ (updates every minute)
           │
           ▼
┌──────────────────────┐
│  AutoThemeService    │ (Auto Features Manager)
│  ────────────────────│
│  • shouldUseDarkTheme│
│  • getCurrentBg()    │
│  • getCurrentSeason()│
│  • autoThemeEnabled  │
│  • autoBgEnabled     │
└──────────┬───────────┘
           │
           │ (notifies listeners)
           │
           ▼
┌──────────────────────┐
│ AppSettingsProvider  │ (State Manager)
│ ────────────────────│
│  • Theme Mode        │
│  • UI Theme          │
│  • Language          │
│  • Voice/Sound       │
└──────────┬───────────┘
           │
           │ (notifies UI)
           │
           ▼
┌──────────────────────────────────────────────────────────┐
│                        UI LAYER                          │
│ ─────────────────────────────────────────────────────────│
│                                                          │
│  ┌─────────────────┐  ┌──────────────┐  ┌────────────┐│
│  │ DashboardScreen │  │ GardenScreen │  │  Settings  ││
│  │ ───────────────│  │ ────────────│  │ ──────────││
│  │ • Location/Time│  │ • Auto-Season│  │ • Toggles  ││
│  │ • Auto BG      │  │ • Music      │  │            ││
│  └─────────────────┘  └──────────────┘  └────────────┘│
└──────────────────────────────────────────────────────────┘
```

## Component Interaction

```
┌───────────────────────────────────────────────────────────────┐
│                    REAL WORLD INPUT                           │
│  GPS Location  •  Device Time  •  Internet APIs               │
└───────────────┬───────────────────────────────────────────────┘
                │
                ▼
┌───────────────────────────────────────────────────────────────┐
│              LocationTimeService (Singleton)                  │
│  ─────────────────────────────────────────────────────────────│
│                                                               │
│  Fetches:                    Provides:                        │
│  • GPS coords (Geolocator)   • currentDateTime               │
│  • Time (WorldTimeAPI)       • cityName / countryName        │
│  • Location (Nominatim)      • timezone                      │
│                              • timeOfDay (enum)              │
│  Updates: Every 1 minute     • currentSeason (enum)          │
│                              • shouldUseDarkTheme (bool)     │
└───────────────┬───────────────────────────────────────────────┘
                │
                │ addListener / notifyListeners
                ▼
┌───────────────────────────────────────────────────────────────┐
│              AutoThemeService (Singleton)                     │
│  ─────────────────────────────────────────────────────────────│
│                                                               │
│  Listens to:                 Provides:                        │
│  • LocationTimeService       • shouldUseDarkTheme()          │
│                              • getCurrentBackgroundImage()   │
│  User Prefs:                 • getCurrentGardenSeason()      │
│  • autoThemeEnabled                                          │
│  • autoBackgroundEnabled     Maps:                           │
│                              • Season → Background Image     │
│  Saved in:                   • Season → Garden Season        │
│  • LocalStorageService       • Time → Theme Mode             │
└───────────────┬───────────────────────────────────────────────┘
                │
                │ addListener / notifyListeners
                ▼
┌───────────────────────────────────────────────────────────────┐
│            AppSettingsProvider (ChangeNotifier)               │
│  ─────────────────────────────────────────────────────────────│
│                                                               │
│  Listens to:                 Manages:                         │
│  • AutoThemeService          • _themeMode                    │
│                              • _uiTheme                      │
│  On Change:                  • _language                     │
│  • Updates theme mode        • _voicePersonality            │
│  • Notifies UI               • _soundEnabled                │
│                                                               │
│  Accessed by:                                                │
│  • MaterialApp (theme)                                       │
│  • All screens via context.watch<AppSettingsProvider>()     │
└───────────────────────────────────────────────────────────────┘
                │
                │ context.watch
                ▼
┌───────────────────────────────────────────────────────────────┐
│                        UI COMPONENTS                          │
│  ─────────────────────────────────────────────────────────────│
│                                                               │
│  Dashboard:                                                   │
│  ┌────────────────────────────────────────────────┐         │
│  │ LocationTimeWidget                             │         │
│  │ • Displays: city, country, time                │         │
│  │ • Updates: every minute                        │         │
│  │ • Design: Glass-morphic, top of dashboard      │         │
│  └────────────────────────────────────────────────┘         │
│                                                               │
│  ┌────────────────────────────────────────────────┐         │
│  │ Dashboard Container (background)               │         │
│  │ • Image: From autoThemeService.getCurrentBg()  │         │
│  │ • Opacity: 15% (subtle)                        │         │
│  │ • Updates: When season changes                 │         │
│  └────────────────────────────────────────────────┘         │
│                                                               │
│  Garden:                                                      │
│  ┌────────────────────────────────────────────────┐         │
│  │ GardenScreen (_initAutoSeason)                 │         │
│  │ • Season: From autoThemeService                │         │
│  │ • Music: season-based (already implemented)    │         │
│  │ • Manual override: Still available             │         │
│  └────────────────────────────────────────────────┘         │
│                                                               │
│  Settings:                                                    │
│  ┌────────────────────────────────────────────────┐         │
│  │ Settings Toggles (General section)             │         │
│  │ • Auto Theme Switch                            │         │
│  │ • Auto Background Switch                       │         │
│  │ • Calls: autoThemeService.setAutoTheme()       │         │
│  └────────────────────────────────────────────────┘         │
└───────────────────────────────────────────────────────────────┘
```

## Time-Based Theme Logic

```
┌─────────────────────────────────────────────────────────┐
│                 Time of Day Detection                   │
└─────────────────────────────────────────────────────────┘

Device Time:
├─ 05:00 - 07:59  →  TimeOfDay.dawn      →  Light Theme
├─ 08:00 - 11:59  →  TimeOfDay.morning   →  Light Theme
├─ 12:00 - 16:59  →  TimeOfDay.afternoon →  Light Theme
├─ 17:00 - 19:59  →  TimeOfDay.dusk      →  Light Theme
└─ 20:00 - 04:59  →  TimeOfDay.night     →  Dark Theme

shouldUseDarkTheme:
  return hour < 6 || hour >= 19  // Dark: 7PM to 6AM
```

## Season-Based Background Logic

```
┌─────────────────────────────────────────────────────────┐
│                   Season Detection                      │
└─────────────────────────────────────────────────────────┘

Current Month:
├─ March - May     →  Season.spring  →  spring.jpeg
├─ June - August   →  Season.summer  →  summer.jpeg
├─ September - Nov →  Season.autumn  →  autumn.jpeg
└─ December - Feb  →  Season.winter  →  winter.jpeg

Special Cases:
├─ Night (any season)      →  winter.jpeg (dark atmosphere)
└─ Monsoon (Jun-Sep)       →  Garden: Monsoon season
```

## Update Cycle

```
┌────────────────────────────────────────────────────────────┐
│                  EVERY 1 MINUTE                            │
└────────────────────────────────────────────────────────────┘
                        │
                        ▼
        ┌───────────────────────────┐
        │ LocationTimeService       │
        │ fetches new data          │
        └───────────┬───────────────┘
                    │
                    ├─ New time from WorldTimeAPI
                    ├─ Recalculate timeOfDay
                    └─ notifyListeners()
                    │
                    ▼
        ┌───────────────────────────┐
        │ AutoThemeService          │
        │ listens & recalculates    │
        └───────────┬───────────────┘
                    │
                    ├─ Check if theme should change
                    ├─ Check if season changed
                    └─ notifyListeners()
                    │
                    ▼
        ┌───────────────────────────┐
        │ AppSettingsProvider       │
        │ updates theme             │
        └───────────┬───────────────┘
                    │
                    ├─ Update _themeMode if needed
                    └─ notifyListeners()
                    │
                    ▼
        ┌───────────────────────────┐
        │ UI Rebuilds               │
        │ • Dashboard               │
        │ • Garden                  │
        │ • All screens             │
        └───────────────────────────┘
```

## API Integration

```
┌─────────────────────────────────────────────────────────────┐
│                    External APIs (FREE)                     │
└─────────────────────────────────────────────────────────────┘

1. WorldTimeAPI
   ├─ URL: http://worldtimeapi.org/api/ip
   ├─ Purpose: Accurate time, timezone, date
   ├─ Cost: FREE
   ├─ API Key: NOT REQUIRED
   └─ Response: { datetime, timezone, ... }

2. OpenStreetMap Nominatim
   ├─ URL: https://nominatim.openstreetmap.org/reverse
   ├─ Purpose: City/country from GPS coordinates
   ├─ Cost: FREE
   ├─ API Key: NOT REQUIRED
   ├─ Params: lat, lon, format=json
   └─ Response: { address: { city, country, ... } }

3. Geolocator (Package)
   ├─ Purpose: Device GPS coordinates
   ├─ Platform: iOS/Android native
   ├─ Requires: Location permission
   └─ Returns: Position(latitude, longitude)
```

## Permission Flow

```
┌─────────────────────────────────────────────────────────────┐
│                  First App Launch                           │
└─────────────────────────────────────────────────────────────┘
                        │
                        ▼
        ┌───────────────────────────┐
        │ LocationTimeService       │
        │ .initialize()             │
        └───────────┬───────────────┘
                    │
                    ▼
        ┌───────────────────────────┐
        │ Check Location Permission │
        └───────────┬───────────────┘
                    │
        ┌───────────┴────────────┐
        │                        │
        ▼                        ▼
   [Granted]               [Denied/Not Set]
        │                        │
        │                        ▼
        │              Request Permission
        │                        │
        │              ┌─────────┴─────────┐
        │              │                   │
        │              ▼                   ▼
        │         [Granted]           [Denied]
        │              │                   │
        └──────────────┴───────────────────┘
                       │
                       ▼
        ┌──────────────────────────┐
        │ Fetch GPS Location       │
        │ Get City/Country         │
        │ Display on Dashboard     │
        └──────────────────────────┘

If Denied:
  • Shows "Unknown Location" on dashboard
  • Time still works (from WorldTimeAPI or device)
  • Auto-theme still works
  • App continues to function normally
```

## State Management

```
┌─────────────────────────────────────────────────────────────┐
│                   ChangeNotifier Pattern                    │
└─────────────────────────────────────────────────────────────┘

LocationTimeService (extends ChangeNotifier)
   │
   ├─ Private state: _currentDateTime, _cityName, etc.
   ├─ Public getters: currentDateTime, cityName, etc.
   ├─ Methods that change state: fetchAllData(), refresh()
   └─ Calls: notifyListeners() when state changes
          │
          └─► All registered listeners get notified
                 │
                 └─► AutoThemeService (listener)

AutoThemeService (extends ChangeNotifier)
   │
   ├─ Private state: _autoThemeEnabled, _autoBackgroundEnabled
   ├─ Public getters: autoThemeEnabled, getCurrentBackgroundImage()
   ├─ Methods: setAutoTheme(), setAutoBackground()
   └─ Calls: notifyListeners() when state changes
          │
          └─► All registered listeners get notified
                 │
                 ├─► AppSettingsProvider (listener)
                 └─► LocationTimeWidget (listener)

AppSettingsProvider (with ChangeNotifier)
   │
   ├─ Private state: _themeMode, _uiTheme, etc.
   ├─ Public getters: themeMode, uiThemeData, autoThemeService
   ├─ Methods: setThemeMode(), toggleTheme()
   └─ Calls: notifyListeners() when state changes
          │
          └─► All widgets using context.watch() rebuild
                 │
                 ├─► MaterialApp (theme)
                 ├─► DashboardScreen
                 ├─► GardenScreen
                 └─► SettingsScreen
```

## Summary

This architecture ensures:
- ✅ Separation of concerns (services, providers, UI)
- ✅ Reactive updates (ChangeNotifier pattern)
- ✅ Efficient rebuilds (only affected widgets update)
- ✅ User control (toggles in settings)
- ✅ Graceful degradation (fallbacks if APIs fail)
- ✅ Privacy-friendly (location stays on device)
- ✅ Free APIs (no costs or keys)
- ✅ Minimal battery impact (updates once per minute)
