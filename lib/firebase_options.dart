import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web platform is not configured for this app.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS is not configured yet. Run FlutterFire CLI to add iOS support.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDEYtZzALHcfU7qlM8K2D7P3EO-Bmez5_M',
    appId: '1:753852053134:android:307a10add49ffd4d457bdf',
    messagingSenderId: '753852053134',
    projectId: 'mindfulnessgarden-a7af7',
    storageBucket: 'mindfulnessgarden-a7af7.firebasestorage.app',
  );
}
