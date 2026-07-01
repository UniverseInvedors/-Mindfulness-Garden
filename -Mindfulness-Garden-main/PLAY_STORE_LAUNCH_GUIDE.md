# 🚀 Play Store Launch Guide — PranaVerse: Healing Frequencies
## From Zero to Live & Earning — Step by Step

**App:** PranaVerse: Healing Frequencies  
**Package:** `com.universeinvedors.pranaverse`  
**Version:** 1.0.0+1  
**AAB:** `build\app\outputs\bundle\release\app-release.aab` (197.6 MB)  
**Goal:** Live on Play Store + earning within 3–5 days

---

## ⏱️ Time Estimate Per Phase

| Phase | What | Time |
|---|---|---|
| 1 | Google Play Console account setup | 30 min |
| 2 | AdMob account + ad units | 20 min |
| 3 | RevenueCat subscription setup | 20 min |
| 4 | Firebase configuration | 15 min |
| 5 | Store listing (assets + copy) | 45 min |
| 6 | Upload AAB + review config | 20 min |
| 7 | Submit for review | 10 min |
| — | Google review period | 1–3 days |

---

## PHASE 1 — Google Play Console Account

### 1.1 Create Developer Account
1. Go to **https://play.google.com/console**
2. Sign in with your Google account (use a permanent business email, not personal)
3. Click **"Get started"**
4. Choose account type: **Individual** (or Organization if you have a business)
5. Fill in:
   - Developer name: `Universe Invedors` (or your brand name — this shows on Play Store)
   - Email address
   - Phone number
6. Pay the **$25 one-time registration fee** (credit/debit card)
7. Wait for verification email — usually instant

### 1.2 Complete Account Setup
1. Go to **Setup → Developer account → Account details**
2. Fill in your real address (required for payments)
3. Go to **Setup → Payment profile**
   - Link a bank account for earnings payout
   - Add your tax information (India: PAN card details)
4. Accept the **Google Play Developer Distribution Agreement**

> ✅ Account is ready when you see the Play Console dashboard

---

## PHASE 2 — AdMob Setup (Start Earning from Ads)

The app uses `google_mobile_ads`. You need real Ad Unit IDs.

### 2.1 Create AdMob Account
1. Go to **https://admob.google.com**
2. Sign in with the **same Google account** as Play Console
3. Complete account setup:
   - Country: India (or yours)
   - Currency: INR (or USD)
   - Payment info (same bank as Play Console)

### 2.2 Add Your App to AdMob
1. In AdMob → **Apps → Add app**
2. Select **Android**
3. Search for your app — it won't appear yet since it's not live
4. Click **"Add app manually"**
   - App name: `PranaVerse: Healing Frequencies`
   - Platform: Android
5. You'll get an **App ID** like: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`

### 2.3 Create Ad Units
Create these 3 ad unit types:

| Ad Unit Name | Type | Where Used |
|---|---|---|
| `pranaverse_banner` | Banner | Bottom of main screens |
| `pranaverse_interstitial` | Interstitial | Between navigation (every 3rd tap) |
| `pranaverse_rewarded` | Rewarded | Premium content unlock |

For each:
1. Click **"Add ad unit"**
2. Choose type → name it → click **Create**
3. Copy the **Ad Unit ID** (format: `ca-app-pub-XXXXX/XXXXXXXXXX`)

### 2.4 Update App with Real Ad IDs
Open `lib/core/services/ad_service.dart` (or wherever ad IDs are configured) and replace test IDs:

```dart
// Replace these with your real AdMob IDs
static const String appId = 'ca-app-pub-YOUR_APP_ID~YOUR_APP_ID';
static const String bannerId = 'ca-app-pub-YOUR_ID/YOUR_BANNER_UNIT';
static const String interstitialId = 'ca-app-pub-YOUR_ID/YOUR_INTERSTITIAL_UNIT';
static const String rewardedId = 'ca-app-pub-YOUR_ID/YOUR_REWARDED_UNIT';
```

Also update `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-YOUR_REAL_APP_ID~YOUR_REAL_APP_ID"/>
```

> ⚠️ After updating ad IDs, rebuild the AAB:
> ```
> flutter clean && flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
> ```

---

## PHASE 3 — RevenueCat Setup (Subscription Earnings)

The app uses `purchases_flutter` for in-app subscriptions (₹199/month, ₹1499/year).

### 3.1 Create RevenueCat Account
1. Go to **https://app.revenuecat.com**
2. Sign up (free for under $2,500/month revenue)
3. Create a new **Project** → name it `PranaVerse`

### 3.2 Add Android App
1. In your project → **+ Add app** → Android
2. Enter package name: `com.universeinvedors.pranaverse`
3. Copy the **RevenueCat Public SDK Key** (starts with `goog_`)

### 3.3 Update App with RevenueCat Key
Find where `Purchases.configure` is called in the app and add your key:
```dart
await Purchases.configure(
  PurchasesConfiguration('goog_YOUR_PUBLIC_SDK_KEY'),
);
```

### 3.4 Create Products in Play Console (do this after Phase 5)
Come back here after uploading your AAB. In Play Console:
1. **Monetize → Products → Subscriptions → Create subscription**
2. Create:
   - Product ID: `mindfulness_premium_monthly` — ₹199/month
   - Product ID: `mindfulness_premium_yearly` — ₹1,499/year
3. Activate both products

### 3.5 Link Play Store to RevenueCat
In RevenueCat → your app → **Credentials**:
1. Upload your Google Play service account JSON key
2. (Get it from Play Console → Setup → API access → Create service account)

---

## PHASE 4 — Firebase Configuration

The app uses Firebase. Make sure the project matches your package name.

### 4.1 Check Firebase Project
1. Go to **https://console.firebase.google.com**
2. Open project `pranaverse` (or create one if missing)
3. Go to **Project settings → General**
4. Under "Your apps" find the Android app with package `com.universeinvedors.pranaverse`
5. If missing → **Add app → Android** → enter package name → download `google-services.json`
6. Replace `android/app/google-services.json` with the downloaded file

### 4.2 Enable Required Firebase Services
In Firebase Console enable:
- **Authentication** → Sign-in methods → Email/Password → Enable
- **Firestore Database** → Create database → Production mode
- **Analytics** → Enable
- **Crashlytics** → Enable (auto with the build)

### 4.3 Add SHA-1 Fingerprint
1. Run: `keytool -list -v -keystore android\app\release-keystore.jks -alias pranaverse`
   - Password: `Pranaverse2024!`
2. Copy the **SHA-1** fingerprint
3. In Firebase → Project settings → Your Android app → Add fingerprint → paste SHA-1

---

## PHASE 5 — Store Listing Assets

You need these assets before you can submit. Create them now.

### 5.1 App Icon ✅ (Already done)
- Adaptive icon generated via `flutter_launcher_icons`
- Already in the AAB

### 5.2 Screenshots (REQUIRED — minimum 2, recommended 8)

**Specifications:**
- Phone: **1080 × 1920 px** (16:9) or **1080 × 2400 px** (20:9) — PNG or JPG
- No device frames required
- No text overlays required (Google policy)

**Recommended screenshots to capture:**

| # | Screen | Route |
|---|---|---|
| 1 | Splash / Loading screen | `/splash` |
| 2 | Home dashboard (main menu) | `/main` |
| 3 | My Garden — summer season | `/garden` |
| 4 | Breathing exercise (Zeno Breathing) | `/breathing/zeno` |
| 5 | Meditation scene (forest environment) | `/scenes` |
| 6 | Yoga with Zeno | `/yoga` |
| 7 | Progress / Stats screen | `/progress` |
| 8 | Subscription / Premium screen | `/subscription` |

**How to take screenshots:**
1. Run app on Android device or emulator
2. Navigate to each screen
3. Use device screenshot button or:
   ```
   adb exec-out screencap -p > screenshot_01_splash.png
   ```
4. Save all as numbered PNG files

### 5.3 Feature Graphic (REQUIRED)
- Size: **1024 × 500 px**
- Format: PNG or JPG
- Content: Your app logo + tagline on a green/nature background
- Canva template suggestion: Search "Google Play Feature Graphic" on canva.com
- Text to use: **"PranaVerse — Breathe. Meditate. Heal."**

### 5.4 Privacy Policy (REQUIRED)
You MUST have a hosted privacy policy URL.

**Quickest option — GitHub Pages:**
1. Go to your public repo: `https://github.com/Innnervision/Mindfulness-Garden`
2. Create a file `privacy-policy.html` with the content below
3. Enable GitHub Pages: Settings → Pages → Deploy from main branch
4. Your URL will be: `https://innnervision.github.io/Mindfulness-Garden/privacy-policy.html`

**Privacy policy minimum content:**
```html
<h1>Privacy Policy — PranaVerse: Healing Frequencies</h1>
<p>Last updated: July 2, 2026</p>
<h2>Data We Collect</h2>
<p>We collect email address (optional, for account creation), 
app activity data (sessions, mood logs, streak), and device identifiers 
for analytics and crash reporting.</p>
<h2>How We Use Data</h2>
<p>To personalize your wellness experience, improve the app, 
and send optional reminders. We do not sell your data.</p>
<h2>Third-Party Services</h2>
<p>Firebase Analytics, Firebase Crashlytics, Google AdMob, RevenueCat.</p>
<h2>Data Deletion</h2>
<p>Email universeinvedors@gmail.com to request account and data deletion.</p>
<h2>Contact</h2>
<p>universeinvedors@gmail.com</p>
```

---

## PHASE 6 — Create App in Play Console

### 6.1 Create the App
1. In Play Console → **"Create app"**
2. Fill in:
   - **App name:** `PranaVerse: Healing Frequencies`
   - **Default language:** English (United States)
   - **App or game:** App
   - **Free or paid:** Free
3. Check both declaration boxes → **Create app**

### 6.2 Store Listing — Main Store Listing
Go to **Grow → Store presence → Main store listing**

**App name (50 chars max):**
```
PranaVerse: Healing Frequencies
```

**Short description (80 chars max):**
```
Yoga, breathing exercises, healing frequencies and meditation journeys
```

**Full description (4000 chars max):** *(copy from RELEASE_BUILD_SUMMARY.md)*

**Graphics:**
- Upload your **Feature graphic** (1024×500)
- Upload your **Screenshots** (minimum 2, upload all 8)
- App icon is auto-pulled from the AAB

**Categorization:**
- App category: **Health & Fitness**
- Tags: Meditation, Yoga, Breathing, Wellness, Mindfulness

**Contact details:**
- Email: your support email
- Privacy Policy URL: your hosted URL from Phase 5.4

### 6.3 Store Listing — Content Rating
1. Go to **Policy → App content → Content rating**
2. Click **Start questionnaire**
3. Category: **Utilities**
4. Answer all questions:
   - Violence: No
   - Sexual content: No
   - Language: No
   - Controlled substances: No
   - User interaction: No (offline app)
5. Submit → Rating: **Everyone (E)**

### 6.4 Store Listing — Data Safety
Go to **Policy → App content → Data safety**

Fill in exactly:

| Data Type | Collected | Shared | Required |
|---|---|---|---|
| Email address | Yes | No | Optional |
| App interactions | Yes | No | Required |
| App diagnostics | Yes | No | Required |
| Device identifiers | Yes | No | Required |

- **Data encrypted in transit:** Yes
- **Users can request deletion:** Yes

### 6.5 Store Listing — Target Audience
1. Go to **Policy → App content → Target audience**
2. Target age: **18 and over**
3. This avoids child content policy complications

### 6.6 App Access
1. Go to **Policy → App content → App access**
2. Select: **All or most functionality is accessible without special access**

---

## PHASE 7 — Upload AAB and Create Release

### 7.1 Upload the App Bundle
1. Go to **Release → Production → Create new release**
2. Click **"Upload"**
3. Select your AAB:
   ```
   d:\Production APPS\Games\MindfulnessGarden\MindfulnessGarden\-Mindfulness-Garden-main\build\app\outputs\bundle\release\app-release.aab
   ```
4. Wait for upload and processing (2–5 min for 197 MB)

### 7.2 Upload Debug Symbols (for Crashlytics)
After the AAB uploads:
1. Click **"Upload debug symbols"** (optional but recommended)
2. Upload files from:
   ```
   d:\Production APPS\Games\MindfulnessGarden\MindfulnessGarden\-Mindfulness-Garden-main\build\debug-info\
   ```

### 7.3 Release Details
- **Release name:** `1.0.0 (1)` (auto-filled from AAB)
- **Release notes (What's new):**
```
Welcome to PranaVerse: Healing Frequencies!

🌱 Your complete wellness companion featuring:
• 6 breathing techniques including Zeno Breathing
• Immersive meditation scenes with 7 environments
• Yoga sessions with 2.5D animated guide
• My Garden — grow plants as you meditate
• Binaural beats, solfeggio frequencies & healing music
• Mood tracking, progress stats & daily challenges
• Beautiful glassmorphism UI with 6 themes

Start your journey to inner peace today.
```

### 7.4 Country / Region Availability
1. Go to **Release → Production → Countries / regions**
2. Click **"Add countries / regions"**
3. Select **"Add all countries and regions"** for maximum reach
   - Or prioritize: India, United States, United Kingdom, Canada, Australia

### 7.5 Review and Roll Out
1. Go back to **Release → Production**
2. Click **"Review release"**
3. Fix any warnings shown (usually missing rating or data safety)
4. Click **"Start rollout to Production"**
5. Confirm: **"Rollout"**

> 🎉 Your app is now submitted for Google review!

---

## PHASE 8 — After Submission (1–3 Days)

### What Happens During Review
- Google automated systems scan the APK (~2 hours)
- Human review may follow for Health & Fitness apps (~1–2 days)
- You'll get an email when approved or if issues are found

### Common Rejection Reasons + Fixes

| Issue | Fix |
|---|---|
| Missing privacy policy | Add the hosted URL from Phase 5.4 |
| Metadata policy violation | Remove any claim of "best", "#1", etc. from description |
| Data safety incomplete | Fill all fields in Phase 6.4 |
| Target API level too low | Already set to SDK 36 — no issue |
| Ad SDK not declared | Already in AndroidManifest — no issue |

### Check Status
- Play Console → **Release → Production** → shows "In review" then "Published"

---

## PHASE 9 — After Going Live (Start Earning)

### 9.1 Verify Ads are Showing
1. Open the live app on a real device
2. Navigate through screens — banner ads should appear at bottom
3. Trigger interstitial: tap through features 3 times
4. Check AdMob dashboard → **Reports** → should show impressions within 24h

### 9.2 Monitor Revenue
- **AdMob:** https://admob.google.com → Reports (updates daily)
- **RevenueCat:** https://app.revenuecat.com → Overview (real-time subscriptions)
- **Play Console:** Monetize → Financial reports (30-day delay)

### 9.3 First Week Targets
- Share the Play Store link everywhere: social media, WhatsApp, friends
- Ask for reviews — 10+ reviews in first week helps ranking
- Play Store link will be:
  ```
  https://play.google.com/store/apps/details?id=com.universeinvedors.pranaverse
  ```

### 9.4 Payment Schedule
- **AdMob:** Pays on 21st of each month, minimum $100 threshold
- **Subscriptions (RevenueCat/Google):** Google pays 15th of month, 30-day holding period
- **Bank transfer:** Linked account in Play Console payment profile

---

## 📋 Quick Checklist — Don't Submit Without These

- [ ] Play Console account created + $25 paid
- [ ] Bank account linked in payment profile
- [ ] AdMob account created + real ad unit IDs in app
- [ ] AAB rebuilt with real ad IDs (if you changed them)
- [ ] RevenueCat SDK key added to app
- [ ] `google-services.json` matches package name
- [ ] SHA-1 fingerprint added to Firebase
- [ ] Privacy policy hosted and URL ready
- [ ] Feature graphic 1024×500 px ready
- [ ] Minimum 2 screenshots (1080×1920 or 1080×2400) ready
- [ ] Store listing fully filled (name, short desc, full desc, category)
- [ ] Content rating questionnaire completed (Everyone)
- [ ] Data safety section filled
- [ ] Target audience set to 18+
- [ ] AAB uploaded to Production release
- [ ] Debug symbols uploaded
- [ ] Release notes written
- [ ] Countries/regions selected (all)
- [ ] Submitted for review

---

## 🔑 Key Credentials to Keep Safe

| Item | Value |
|---|---|
| Package name | `com.universeinvedors.pranaverse` |
| Keystore file | `android/app/release-keystore.jks` |
| Key alias | `pranaverse` |
| Keystore password | `Pranaverse2024!` |
| Key password | `Pranaverse2024!` |

> ⚠️ **NEVER lose the keystore file.** Back it up to Google Drive, Dropbox AND email it to yourself. If you lose it, you can never update the app — you'd have to publish a new app with a new package name and lose all your reviews and installs.

---

## 💰 Revenue Projection (Realistic)

| Month | Downloads | Ad Revenue | Subscriptions | Total |
|---|---|---|---|---|
| Month 1 | 100–500 | ₹500–2,000 | ₹0–2,000 | ₹500–4,000 |
| Month 3 | 500–2,000 | ₹2,000–8,000 | ₹2,000–10,000 | ₹4,000–18,000 |
| Month 6 | 2,000–10,000 | ₹8,000–40,000 | ₹10,000–50,000 | ₹18,000–90,000 |

Growth depends on ASO (App Store Optimization), reviews, and promotion. The Health & Fitness category has strong conversion to paid subscriptions.

---

*Guide created: July 2, 2026 | App: PranaVerse v1.0.0+1*
