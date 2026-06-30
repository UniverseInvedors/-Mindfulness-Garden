# 🧘 Mindfulness Garden

> **Grow your inner peace through meditation, wellness tracking, and a gamified garden experience.**

![Mindfulness Garden Hero](screenshot_web.png)

---

## 🌿 Project Overview

**Mindfulness Garden** is a wellness app that turns daily meditation into a living garden. It combines guided breathing, AI coaching, mood tracking, biometric feedback, and community support.

This repository is GitHub-ready with full documentation, architecture overview, and startup instructions.

---

## ✨ Core Features

- **Guided meditation** sessions and breathing exercises
- **Interactive garden** growth system tied to daily progress
- **AI coach** for personalized recommendations
- **Mood and sleep tracking** with charts
- **Biometric integration** for heart rate and health insights
- **Community challenges** and friend support
- **Premium subscription** and in-app content packs

---

## 🌟 User Experience

### Meditation & Breathing
- Zeno, 4-7-8, Box Breathing, Breath Awareness
- Guided audio and cinematic video sessions
- Ambient soundscapes and binaural options

### Wellness Tracking
- Mood tracker with analytics
- Sleep logging and daily continuity
- Streak rewards and achievement badges

### Garden Growth
- Plant new species with meditation progress
- Water, harvest, and unlock garden zones
- Seasonal visuals and particle effects

---

## 📷 Screenshots

![Splash](screenshots/01_splash.png)
![Main Dashboard](screenshots/02_main.png)
![Garden](screenshots/04_garden.png)
![Breathing](screenshots/05_breathing.png)
![Mood Tracker](screenshots/06_mood.png)

---

## 🏗️ Repository Structure

```
lib/
├── main.dart
├── core/
├── features/
├── models/
└── services/
```

Key folders:
- `core/` for theme, localization, and analytics
- `features/` for meditation, garden, mood tracking, and community
- `models/` for user data, sessions, and achievements
- `services/` for Firebase and RevenueCat integration

---

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| Flutter | Cross-platform UI |
| flutter_bloc + Provider | State management |
| Firebase | Auth, Firestore, Storage, Messaging, Analytics |
| RevenueCat | Subscriptions |
| just_audio + audioplayers | Meditation audio |
| video_player + chewie | Guided video playback |
| flutter_tts | Text-to-speech guidance |
| sensors_plus + health | Biometric input |
| Hive + SQLite | Local persistence |
| FL Chart | Progress analytics |
| flutter_animate + Lottie | Animations |
| GoRouter + AutoRoute | Navigation |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.4.0
- Firebase project configured with `flutterfire configure`
- RevenueCat account (optional)
- AdMob account (optional)

### Run locally

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Run on web

```bash
flutter run -d chrome
```

---

## 📱 Supported Platforms

- Android
- iOS
- Web
- Windows
- macOS
- Linux

---

## 📝 License

Proprietary — All rights reserved.
