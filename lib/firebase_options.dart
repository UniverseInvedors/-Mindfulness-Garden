import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBm4ocyxpX638Uw03e9xdE2qDC9hrvLIrw',
    appId: '1:588170884079:android:842380d642d9b22e017c1a',
    messagingSenderId: '588170884079',
    projectId: 'uno-color-clash-game',
    storageBucket: 'uno-color-clash-game.firebasestorage.app',
  );
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAqxja8V80le71Fxh2NPBydMLE746Q3EqE',
    appId: '1:588170884079:web:834eafcf3f923705017c1a',
    messagingSenderId: '588170884079',
    projectId: 'uno-color-clash-game',
    authDomain: 'uno-color-clash-game.firebaseapp.com',
    storageBucket: 'uno-color-clash-game.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyASVRZUmIiXNOxDm30OzrbOEgPzvdURJpc',
    appId: '1:588170884079:ios:f5c9b78b53280f2a017c1a',
    messagingSenderId: '588170884079',
    projectId: 'uno-color-clash-game',
    storageBucket: 'uno-color-clash-game.firebasestorage.app',
    iosClientId: '588170884079-g491gc2mk43g1jq9qh6qjlov89guk830.apps.googleusercontent.com',
    iosBundleId: 'com.example.mindfulnessGarden',
  );
}
