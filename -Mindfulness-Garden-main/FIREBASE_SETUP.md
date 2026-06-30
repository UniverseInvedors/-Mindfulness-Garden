# Firebase Setup — PranaVerse (Mindfulness Garden)
## Project: `games-9bec6`

---

## 1. Register the Android app in Firebase Console

1. Open https://console.firebase.google.com/project/games-9bec6/settings/general
2. Click **Add app → Android**
3. Package name: `com.universeinvedors.pranaverse`
4. App nickname: `PranaVerse`
5. Download **google-services.json** → place it at `android/app/google-services.json`

---

## 2. Register the iOS app (optional but recommended)

1. Click **Add app → iOS** in the same project settings page
2. Bundle ID: `com.universeinvedors.pranaverse`
3. Download **GoogleService-Info.plist** → place it at `ios/Runner/GoogleService-Info.plist`

---

## 3. Run FlutterFire CLI (regenerates firebase_options.dart with real values)

```bash
# Install the CLI (one-time)
dart pub global activate flutterfire_cli

# From the project root (MindfulnessGarden/MindfulnessGarden/)
flutterfire configure --project=games-9bec6
```

This will overwrite `lib/firebase_options.dart` with real API keys and app IDs.

---

## 4. Enable Firebase services in the Console

Go to https://console.firebase.google.com/project/games-9bec6

| Service | Console path | Notes |
|---|---|---|
| **Authentication** | Build → Authentication → Sign-in method | Enable: Email/Password, Google, Phone |
| **Email Verification** | Enabled automatically with Email/Password | Customise template under Templates tab |
| **Phone OTP** | Under Authentication → Sign-in method → Phone | Add test numbers for dev |
| **Firestore** | Build → Firestore Database → Create database | Start in **production mode** then add rules below |
| **Cloud Messaging** | Build → Cloud Messaging | Auto-enabled; add server key to backend |
| **Analytics** | Already enabled for all projects | |
| **Crashlytics** | Build → Crashlytics → Set up Crashlytics | First crash report sets it up |
| **Remote Config** | Build → Remote Config | Add `feature_garden_v2: false` key |

---

## 5. Firestore Security Rules (paste in Console)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can only read/write their own document
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;

      // Sub-collections (sessions, moods, achievements)
      match /{subcollection}/{docId} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }
    }

    // Leaderboard: anyone authenticated can read, only owner can write
    match /leaderboard/{entry} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == entry;
    }
  }
}
```

---

## 6. Authentication → Email Templates

Customise these under **Authentication → Templates**:
- **Email verification** — update from/reply-to address and brand name to "PranaVerse"
- **Password reset** — same branding

---

## 7. Phone OTP test numbers (for dev/CI)

In **Authentication → Sign-in method → Phone → Phone numbers for testing**:
```
+1 650-555-3434  →  123456
+1 650-555-1111  →  654321
```

---

## 8. Google Sign-In SHA-1 fingerprint (Android)

Firebase → Project Settings → Your apps → Android app → Add fingerprint

```bash
# Debug
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Release (use your upload keystore)
keytool -list -v -keystore android/app/upload-keystore.jks -alias <alias>
```

Paste the **SHA-1** value into the Firebase Console.

---

## 9. FCM — Android notification icon

FCM defaults to the app icon. To use a custom small icon:
1. Place a white-on-transparent 96×96 PNG at `android/app/src/main/res/drawable/ic_notification.png`
2. In `FcmService`, change `icon: '@mipmap/ic_launcher'` to `icon: '@drawable/ic_notification'`

---

## 10. Verify everything works

```bash
flutter run --debug
```

Check the debug console for:
```
✅ Firebase Analytics + Crashlytics ready
✅ FCM service initialized
🔑 FCM token: <long token string>
```

Then sign up with a new email — you should receive a verification email from Firebase.
```
