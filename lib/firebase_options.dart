// lib/firebase_options.dart
// Firebase configuration for PranaVerse — project: games-9bec6
// Project number : 885156577376
// Auto-generated from google-services.json + Firebase Console.
//
// To regenerate:  flutterfire configure --project=games-9bec6

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── Android ────────────────────────────────────────────────────────────────
  // Package: com.universeinvedors.pranaverse
  // App ID:  1:885156577376:android:5145c0e85ffae03fda8305
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCywudVwLZu1Dww2nRjrFw8pNEnZul8hAM',
    appId: '1:885156577376:android:5145c0e85ffae03fda8305',
    messagingSenderId: '885156577376',
    projectId: 'games-9bec6',
    storageBucket: 'games-9bec6.firebasestorage.app',
  );

  // ── iOS ────────────────────────────────────────────────────────────────────
  // Register in Firebase Console → games-9bec6 → Add iOS app
  // Bundle ID: com.universeinvedors.pranaverse
  // Then download GoogleService-Info.plist → ios/Runner/
  // and run: flutterfire configure --project=games-9bec6
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey:
        'AIzaSyCywudVwLZu1Dww2nRjrFw8pNEnZul8hAM', // replace after iOS app registration
    appId:
        '1:885156577376:ios:0000000000000000da8305', // replace after iOS app registration
    messagingSenderId: '885156577376',
    projectId: 'games-9bec6',
    storageBucket: 'games-9bec6.firebasestorage.app',
    iosBundleId: 'com.universeinvedors.pranaverse',
  );

  // ── Web ────────────────────────────────────────────────────────────────────
  // Register a web app in Firebase Console → games-9bec6 → Add Web app
  // Then replace values below with the provided config snippet.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCywudVwLZu1Dww2nRjrFw8pNEnZul8hAM',
    appId:
        '1:885156577376:web:0000000000000000da8305', // replace after web app registration
    messagingSenderId: '885156577376',
    projectId: 'games-9bec6',
    authDomain: 'games-9bec6.firebaseapp.com',
    storageBucket: 'games-9bec6.firebasestorage.app',
  );
}
