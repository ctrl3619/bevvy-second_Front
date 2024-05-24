// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDoq24xN9oNP84TwbRxYDLdAc-fkajs5y0',
    appId: '1:26975702543:web:d8dcd01f178f5a16e21d7a',
    messagingSenderId: '26975702543',
    projectId: 'bevvy-91cf0',
    authDomain: 'bevvy-91cf0.firebaseapp.com',
    storageBucket: 'bevvy-91cf0.appspot.com',
    measurementId: 'G-38GSP46ZEF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDIEiGzYNEudYVmcDaO4V1NkKC3-1E9Uv8',
    appId: '1:26975702543:android:56473c57c8593064e21d7a',
    messagingSenderId: '26975702543',
    projectId: 'bevvy-91cf0',
    storageBucket: 'bevvy-91cf0.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBP2fcSVRiqSzJbGbrHg6DDmNZA6bs-pkI',
    appId: '1:26975702543:ios:d74e1688e341e469e21d7a',
    messagingSenderId: '26975702543',
    projectId: 'bevvy-91cf0',
    storageBucket: 'bevvy-91cf0.appspot.com',
    iosBundleId: 'com.example.bevvy',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBP2fcSVRiqSzJbGbrHg6DDmNZA6bs-pkI',
    appId: '1:26975702543:ios:d74e1688e341e469e21d7a',
    messagingSenderId: '26975702543',
    projectId: 'bevvy-91cf0',
    storageBucket: 'bevvy-91cf0.appspot.com',
    iosBundleId: 'com.example.bevvy',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDoq24xN9oNP84TwbRxYDLdAc-fkajs5y0',
    appId: '1:26975702543:web:d8928c3c7dc637e2e21d7a',
    messagingSenderId: '26975702543',
    projectId: 'bevvy-91cf0',
    authDomain: 'bevvy-91cf0.firebaseapp.com',
    storageBucket: 'bevvy-91cf0.appspot.com',
    measurementId: 'G-L8HD5FWCDP',
  );
}
