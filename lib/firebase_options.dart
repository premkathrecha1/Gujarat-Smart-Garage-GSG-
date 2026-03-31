// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
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
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCdFfO7c0w2xaW-qVm3SOdTA8hBPUVitto',
    appId: '1:226169478272:android:f26c58bfb0771bcec49a65',
    messagingSenderId: '226169478272',
    projectId: 'gujarat-smart-garage',
    storageBucket: 'gujarat-smart-garage.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCdFfO7c0w2xaW-qVm3SOdTA8hBPUVitto',
    appId: '1:226169478272:ios:YOUR_IOS_APP_ID', // You'll need to add iOS app
    messagingSenderId: '226169478272',
    projectId: 'gujarat-smart-garage',
    storageBucket: 'gujarat-smart-garage.firebasestorage.app',
    iosBundleId: 'com.example.smartGarageGujarat',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCdFfO7c0w2xaW-qVm3SOdTA8hBPUVitto',
    appId: '1:226169478272:web:YOUR_WEB_APP_ID', // You'll need to add web app
    messagingSenderId: '226169478272',
    projectId: 'gujarat-smart-garage',
    authDomain: 'gujarat-smart-garage.firebaseapp.com',
    storageBucket: 'gujarat-smart-garage.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCdFfO7c0w2xaW-qVm3SOdTA8hBPUVitto',
    appId: '1:226169478272:macos:YOUR_MACOS_APP_ID',
    messagingSenderId: '226169478272',
    projectId: 'gujarat-smart-garage',
    storageBucket: 'gujarat-smart-garage.firebasestorage.app',
  );
}