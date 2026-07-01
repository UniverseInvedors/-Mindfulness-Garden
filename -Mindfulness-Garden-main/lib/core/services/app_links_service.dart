// lib/core/services/app_links_service.dart
//
// Fetches live app store URLs and invite copy from Firebase Remote Config.
//
// ── How to update links after release (no app update required) ──────────────
// 1. Open Firebase Console → Remote Config
// 2. Add / edit the keys listed in the _defaults map below
// 3. Publish the changes
// 4. The app picks up new values within 12 hours (or immediately on next cold
//    start after the minimum fetch interval has elapsed)
// ────────────────────────────────────────────────────────────────────────────

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class AppLinksService {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final AppLinksService _instance = AppLinksService._internal();
  factory AppLinksService() => _instance;
  AppLinksService._internal();

  // ── Remote Config keys ────────────────────────────────────────────────────
  static const _keyPlayStore   = 'play_store_url';
  static const _keyAppStore    = 'app_store_url';
  static const _keyShareUrl    = 'share_url';       // Used in share text
  static const _keyShareText   = 'share_text';      // Full invite message
  static const _keyShareTags   = 'share_hashtags';

  // ── Fallback defaults (used before release / if fetch fails) ─────────────
  // Replace these once you have the real store URLs — they also act as the
  // in-app default so things work during development.
  static const _defaults = {
    _keyPlayStore: 'https://play.google.com/store/apps/details?id=com.pranaverse.app',
    _keyAppStore:  'https://apps.apple.com/app/pranaverse/id000000000',
    _keyShareUrl:  'https://pranaverse.app',       // Placeholder until live
    _keyShareText:
        '🌿 I\'ve been meditating with Mindfulness Garden (PranaVerse) — '
        'my streak is going strong! Join me and grow your inner peace. '
        '🧘 Download now: {url}',                  // {url} replaced at runtime
    _keyShareTags:
        '#MindfulnessGarden #Meditation #PranaVerse #Mindfulness #Wellness',
  };

  bool _initialized = false;

  // ── Initialise (call once at app start, non-blocking) ────────────────────
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final rc = FirebaseRemoteConfig.instance;

      await rc.setConfigSettings(RemoteConfigSettings(
        // In debug/profile builds, fetch every 30 s so you can test changes
        // quickly. In release, respect Firebase's recommended 12-hour interval.
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kReleaseMode
            ? const Duration(hours: 12)
            : const Duration(seconds: 30),
      ));

      await rc.setDefaults(_defaults);

      // Fetch + activate in the background; if it fails the defaults are used.
      await rc.fetchAndActivate();
      _initialized = true;

      if (kDebugMode) {
        debugPrint('✅ AppLinksService: Remote Config fetched');
        debugPrint('   shareUrl  = ${shareUrl}');
        debugPrint('   playStore = ${playStoreUrl}');
      }
    } catch (e) {
      // Never crash the app over a Remote Config fetch failure.
      if (kDebugMode) debugPrint('⚠️ AppLinksService init failed: $e');
      _initialized = true; // Mark as done so we use defaults gracefully
    }
  }

  // ── Accessors ─────────────────────────────────────────────────────────────

  String get playStoreUrl =>
      FirebaseRemoteConfig.instance.getString(_keyPlayStore).isNotEmpty
          ? FirebaseRemoteConfig.instance.getString(_keyPlayStore)
          : _defaults[_keyPlayStore]!;

  String get appStoreUrl =>
      FirebaseRemoteConfig.instance.getString(_keyAppStore).isNotEmpty
          ? FirebaseRemoteConfig.instance.getString(_keyAppStore)
          : _defaults[_keyAppStore]!;

  String get shareUrl =>
      FirebaseRemoteConfig.instance.getString(_keyShareUrl).isNotEmpty
          ? FirebaseRemoteConfig.instance.getString(_keyShareUrl)
          : _defaults[_keyShareUrl]!;

  String get shareHashtags =>
      FirebaseRemoteConfig.instance.getString(_keyShareTags).isNotEmpty
          ? FirebaseRemoteConfig.instance.getString(_keyShareTags)
          : _defaults[_keyShareTags]!;

  /// The full invite message with the live URL injected.
  String get shareText {
    final template =
        FirebaseRemoteConfig.instance.getString(_keyShareText).isNotEmpty
            ? FirebaseRemoteConfig.instance.getString(_keyShareText)
            : _defaults[_keyShareText]!;
    return template.replaceAll('{url}', shareUrl);
  }

  /// Convenience: returns the most appropriate download link for the current
  /// platform (Android → Play Store, iOS → App Store).
  String get platformStoreUrl {
    // Use defaultTargetPlatform so this works in tests too.
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return appStoreUrl;
    }
    return playStoreUrl;
  }
}
