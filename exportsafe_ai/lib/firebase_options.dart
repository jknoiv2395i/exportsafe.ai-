import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart' show TargetPlatform;

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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError('Linux not supported');
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCMqeALFDQY--F0e-ZaMjIgzaEtwzJLo-s',
    appId: '1:1013397762150:web:19ec2b525a90b452227da7',
    messagingSenderId: '1013397762150',
    projectId: 'exportsafe-6b942',
    authDomain: 'exportsafe-6b942.firebaseapp.com',
    storageBucket: 'exportsafe-6b942.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForAndroid',
    appId: '1:123456789:android:abcdef1234567890',
    messagingSenderId: '123456789',
    projectId: 'exportsafe-ai',
    databaseURL: 'https://exportsafe-ai.firebaseio.com',
    storageBucket: 'exportsafe-ai.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForIOS',
    appId: '1:123456789:ios:abcdef1234567890',
    messagingSenderId: '123456789',
    projectId: 'exportsafe-ai',
    databaseURL: 'https://exportsafe-ai.firebaseio.com',
    storageBucket: 'exportsafe-ai.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForMacOS',
    appId: '1:123456789:macos:abcdef1234567890',
    messagingSenderId: '123456789',
    projectId: 'exportsafe-ai',
    databaseURL: 'https://exportsafe-ai.firebaseio.com',
    storageBucket: 'exportsafe-ai.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForWindows',
    appId: '1:123456789:windows:abcdef1234567890',
    messagingSenderId: '123456789',
    projectId: 'exportsafe-ai',
    databaseURL: 'https://exportsafe-ai.firebaseio.com',
    storageBucket: 'exportsafe-ai.appspot.com',
  );
}
