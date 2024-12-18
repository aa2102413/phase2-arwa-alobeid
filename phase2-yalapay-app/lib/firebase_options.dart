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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCB6GT90uhPUqE_lNHOBaYaCGbn4OZUmGM',
    appId: '1:966547949052:web:d63f2def17bbb604871e79',
    messagingSenderId: '966547949052',
    projectId: 'yalapay-752f8',
    authDomain: 'yalapay-752f8.firebaseapp.com',
    storageBucket: 'yalapay-752f8.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCxC8tCBqs6xOn1oqqxPMI5FTlIT_PwFmo',
    appId: '1:966547949052:android:51c174f52b97714a871e79',
    messagingSenderId: '966547949052',
    projectId: 'yalapay-752f8',
    storageBucket: 'yalapay-752f8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC4lLFTExE5oJM0DoBP3xiIgx4HkQFYSCE',
    appId: '1:966547949052:ios:d1677512930ab76f871e79',
    messagingSenderId: '966547949052',
    projectId: 'yalapay-752f8',
    storageBucket: 'yalapay-752f8.firebasestorage.app',
    iosBundleId: 'com.example.yalapay',
  );
}
