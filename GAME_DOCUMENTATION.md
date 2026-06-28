# Mindfulness Garden — Complete Technical Documentation

> **Package name:** `pranaverse` · **Version:** 1.0.0+1 · **Last updated:** June 2026

---

## 1. Overview

**Mindfulness Garden** (published as *PranaVerse*) is a production-grade Flutter wellness application that turns daily meditation, yoga, and breathing practice into a living, interactive garden experience. Users grow a real-time 2.5D mindfulness sanctuary powered by their actual wellness activity — every session plants seeds, every streak unlocks rare species, and an AI companion named Zeno personalises every recommendation.

### Core value proposition
- Guided meditation, breathing, yoga, and sleep in a single coherent app
- Gamified garden that reflects real user consistency
- Medicine-free longevity and body self-healing content (premium)
- AI wellness coach with mood-aware daily planning
- Full offline capability with optional Firebase cloud sync

---

## 2. Technology Stack

| Layer | Technology | Version |
|---|---|---|
| Framework | Flutter | ≥3.4.0 |
| State (UI) | Provider + ChangeNotifier | ^6.1.2 |
| State (domain) | Flutter Riverpod | ^2.4.9 |
| Navigation | GoRouter | ^17.1.0 |
| DI | get_it | ^9.2.0 |
| Local DB | Hive + HiveFlutter | ^2.2.3 / ^1.1.0 |
| Local DB 2 | SQLite (sqflite) | ^2.3.3+1 |
| Preferences | SharedPreferences | ^2.2.2 |
| Firebase Auth | firebase_auth | ^5.5.4 |
| Firebase Firestore | cloud_firestore | ^5.6.9 |
| Firebase Analytics | firebase_analytics | ^11.4.6 |
| Firebase Crashlytics | firebase_crashlytics | ^4.3.5 |
| Firebase Messaging | firebase_messaging | ^15.2.6 |
| Firebase Remote Config | firebase_remote_config | ^5.4.6 |
| Firebase Storage | firebase_storage | ^12.4.6 |
| Subscriptions | purchases_flutter (RevenueCat) | ^9.12.2 |
| Ads | google_mobile_ads | ^5.3.1 |
| Self-hosted analytics | shared_analytics (local path) | 1.0.0 |
| Charts | fl_chart | ^1.1.1 |
| Animations | flutter_animate | ^4.5.2 |
| Game engine | Flame | ^1.16.0 |
| Audio | just_audio, audioplayers, flutter_sound, flutter_tts | various |
| Video | video_player + chewie | ^2.9.1 / ^1.8.5 |
| Biometrics | sensors_plus, pedometer, health | various |
| HTTP | dio | ^5.7.0 |
| Sharing | share_plus | ^12.0.1 |

---

## 3. Architecture

```
lib/
├── main.dart                        # Bootstrap — Firebase, AdMob, FCM, Sound, Analytics
├── firebase_options.dart
├── core/
│   ├── config.dart                  # kDevelopmentAuthMode flag
│   ├── providers/
│   │   └── app_settings_provider.dart  # Theme, language, voice, sound — single source of truth
│   ├── services/
│   │   ├── ad_service.dart          # All 4 AdMob formats + UX rules + premium bypass
│   │   ├── analytics_service.dart   # Firebase Analytics + Crashlytics
│   │   ├── auth_service.dart
│   │   ├── fcm_service.dart
│   │   ├── firestore_service.dart
│   │   ├── sound_service.dart
│   │   ├── voice_service.dart
│   │   └── wallet_service.dart
│   ├── themes/
│   │   ├── app_theme.dart           # 6 deep dark themes, all white-text, accent pops
│   │   └── app_ui_theme.dart        # Alternative theme model (legacy)
│   ├── responsive/                  # ResponsiveScope, breakpoints, grid
│   ├── utils/responsive_helper.dart
│   └── widgets/
│       ├── glassmorphism/           # GlassCard, GlassContainer, GlassButton, GlassIcon
│       ├── breathing_visualizer.dart
│       ├── enhanced_garden_widget.dart
│       ├── meditation_scene_widget.dart
│       └── character/               # TeacherAvatar, TeacherPersonality
├── data/
│   ├── local_storage/local_storage_service.dart
│   ├── models/                      # UserModel, SessionModel, MoodModel, AchievementModel…
│   └── repositories/                # UserRepository, SessionRepository, MoodRepository…
├── features/
│   ├── achievements/
│   ├── ai_coach/                    # AiCoachScreen — Zeno AI chat
│   ├── auth/                        # AuthScreen — email/password + phone OTP + Google
│   ├── biometrics/
│   ├── brainwaves/
│   ├── breathing/                   # 6 exercise screens + menu
│   ├── challenges/                  # DailyChallengesScreen
│   ├── community/
│   ├── dashboard/                   # DashboardScreen — stats, plan, garden, rewards
│   ├── garden/                      # GardenScreen + Flame engine + entities + systems
│   ├── journey/
│   ├── meditation/
│   ├── mood_tracker/
│   ├── music/
│   ├── practice/
│   ├── profile/                     # ProfileScreen — 4-tab (Profile, Health, Settings, Premium)
│   ├── progress/
│   ├── scenes/
│   ├── settings/                    # SettingsScreen — 6 deep themes, voice, sound, teacher
│   ├── sleep/
│   ├── sound_therapy/
│   ├── subscription/                # SubscriptionScreen — AAA paywall
│   ├── teacher/
│   ├── welcome/                     # WelcomeScreen — post-login 5-page feature carousel
│   └── yoga/
├── l10n/                            # EN, BN, HI — ARB + generated Dart
└── presentation/
    ├── providers/                   # ChangeNotifier versions of all providers
    ├── routes/app_router.dart       # GoRouter — 30+ named routes
    └── screens/
        ├── analytics_screen.dart    # Wellness Insights — shared_analytics dashboard
        ├── main_menu.dart           # MainMenuScreen — 2.5D hero + feature rows
        └── splash_screen.dart
```

### State management pattern
The app uses **two parallel patterns** intentionally:
- **Provider (ChangeNotifier)** — UI layer: `AppSettingsProvider`, `AuthProvider`, `UserProvider`, `SessionProvider`, `MoodProvider`, `SubscriptionProvider`, `WalletProvider`
- **Riverpod StateNotifierProvider** — domain layer: `authProvider`, `teacherPreferenceProvider`, `themePreferenceProvider`

Both are registered in `main.dart` via `ProviderScope` wrapping `MultiProvider`.

---

## 4. Theme System

Six deep dark themes — all backgrounds are near-black saturated colour, all text is white, accent colours are high-saturation neon pops for strong contrast and kid appeal.

| Theme | Background | Primary | Accent |
|---|---|---|---|
| 🌿 Garden Serenity | `#061410` jungle black | `#39D353` leaf green | `#B7FF6E` neon lime |
| ☁️ Sky Calm | `#03052A` midnight navy | `#00D4FF` electric cyan | `#7BFFF5` aqua glow |
| 🌅 Sunrise Glow | `#180A00` dark mahogany | `#FF8500` fire orange | `#FFE566` neon gold |
| 🌹 Rose Harmony | `#1A0008` deep crimson | `#FF3D6E` vivid hot rose | `#FF6FD8` neon fuchsia |
| 💜 Lavender Dream | `#0C0015` violet black | `#AA44FF` vivid violet | `#FF6BF5` pink-purple flash |
| 🌙 Midnight Zen *(default)* | `#07071A` obsidian | `#4D6EFF` electric indigo | `#64DFFF` starlight cyan |

`AppTheme.buildTheme()` produces a single `ThemeData` for all six. All themes use `Brightness.dark`, `onSurface: Colors.white`, and the accent is mapped to `tertiary` in the `ColorScheme` so widgets using `colorScheme.tertiary` automatically get the neon pop colour.

Persisted to `LocalStorageService` via `AppSettingsProvider.setUiTheme()`.


---

## 5. Navigation (GoRouter)

All routes are declared in `lib/presentation/routes/app_router.dart`.

| Route | Screen | Transition |
|---|---|---|
| `/splash` | SplashScreen | Fade |
| `/auth` | AuthScreen | Slide from bottom |
| `/welcome` | WelcomeScreen | Fade (query param `?name=`) |
| `/main` | MainMenuScreen | Fade |
| `/dashboard` | DashboardScreen | Slide right |
| `/garden` | GardenScreen | Slide right |
| `/breathing` | BreathingMenuScreen | Slide right |
| `/breathing/zeno` | ZenoBreathingScreen | Slide right |
| `/breathing/box` | BoxBreathingScreen | Slide right |
| `/breathing/478` | Breathing478Screen | Slide right |
| `/breathing/awareness` | BreathAwarenessScreen | Slide right |
| `/breathing/alternate` | AlternateNostrilScreen | Slide right |
| `/breathing/diaphragmatic` | DiaphragmaticBreathingScreen | Slide right |
| `/meditation` | GuidedMeditationScreen | Slide right |
| `/guided-meditation` | GuidedMeditationScreen | Slide right |
| `/audio-meditation` | AudioMeditationScreen | Slide right |
| `/scenes` | SceneManager | Default |
| `/yoga` | YogaSceneScreen | Slide up + fade |
| `/mood-tracker` | MoodTrackerScreen | Slide right |
| `/progress` | ProgressScreen | Slide right |
| `/sleep` | SleepTrackingScreen | Slide right |
| `/sound-therapy` | SoundTherapyScreen | Slide right |
| `/music` | MeditationMusicScreen | Slide right |
| `/binaural-beats` | BinauralBeatsScreen | Slide right |
| `/challenges` | DailyChallengesScreen | Slide right |
| `/achievements` | AchievementsScreen | Slide right |
| `/ai-coach` | AiCoachScreen | Slide right |
| `/heart-rate` | HeartRateScreen | Slide right |
| `/friends` | FriendsScreen | Slide right |
| `/subscription` | SubscriptionScreen | Slide right |
| `/analytics` | AnalyticsScreen | Default |
| `/settings` | SettingsScreen | Slide right |
| `/profile` | ProfileScreen | Slide right |
| `/teachers` | TeacherSelectionScreen | Default |

**Post-auth flow:** `SplashScreen → /auth → /welcome?name=<firstName> → /main`

---

## 6. Authentication

Two parallel implementations exist (both registered, UI uses ChangeNotifier version):

### `presentation/providers/auth_provider.dart` (ChangeNotifier — used by UI)
- Email/password sign-up + sign-in
- Google Sign-In
- Phone OTP with country picker (100+ countries) and link-to-current-user flow
- Email verification dialog
- Forgot password
- `kDevelopmentAuthMode` skips OTP/email-verification in dev
- Syncs user to Firestore + `LocalStorageService` cache

### `core/providers/auth_provider.dart` (Riverpod StateNotifier — domain)
- Same capabilities, immutable `AuthState` + `copyWith`
- `authProvider`, `isAuthenticatedProvider`, `isEmailVerifiedProvider` convenience selectors

### Auth screen features
- Toggle Sign Up / Sign In
- Toggle Email/Password vs Phone OTP
- Country picker bottom sheet with search
- "Continue Offline" → `/dashboard`

---

## 7. Ad System (`AdService`)

Four AdMob formats fully wired and production-ready.

| Format | Ad Unit ID | Placement rule |
|---|---|---|
| Banner | `9917112645` | Always-on above bottom nav bar via `AdBannerWidget` |
| Interstitial | `7946221708` | Every 3rd menu nav tap — max 1 per 3 minutes |
| Rewarded | `3009796315` | User opt-in "Watch ad for +10 seeds" via `RewardedAdButton` |
| Rewarded Interstitial | `6635671042` | Post-session bonus — user opt-in |

**Key rules:**
- Debug builds use Google test IDs automatically via `kDebugMode`
- Premium subscribers (`SubscriptionProvider.isPremiumUser()`) never see ads — `AdService.setPremium(true)` disposes all loaded ads instantly
- Exponential backoff retry on load failure: 5 s → 20 s → 60 s, max 3 attempts
- `MobileAds.updateRequestConfiguration` sets `maxAdContentRating: g` (general audiences)
- `AdService.initialize()` called non-blocking in `main()` — never delays app start
- Premium state synced automatically in `MindfulnessGardenApp` builder via `SubscriptionProvider`

**Reusable widgets:**
- `AdBannerWidget` — `StatefulWidget`, loads its own ad, zero height when unloaded
- `RewardedAdButton` — styled CTA with loading state, success/unavailable snackbars

