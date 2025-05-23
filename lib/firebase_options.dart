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
    apiKey: 'AIzaSyBmRFHYceQXtURTD2ATdGRimRDzYpw9NIc',
    appId: '1:704594678101:web:d773c8ce7a5315671c1fdc',
    messagingSenderId: '704594678101',
    projectId: 'itinerarios-70663',
    authDomain: 'itinerarios-70663.firebaseapp.com',
    storageBucket: 'itinerarios-70663.firebasestorage.app',
    measurementId: 'G-NX6KRTLPBD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA2bbTFBQrkkBjxYgFhL8cnmE1E7M6g7qk',
    appId: '1:704594678101:android:8f4b63e87560d7551c1fdc',
    messagingSenderId: '704594678101',
    projectId: 'itinerarios-70663',
    storageBucket: 'itinerarios-70663.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBSfc_DRu5B6EDfNqXOUmmmsVy2vEtOs7o',
    appId: '1:704594678101:ios:0a5a74f10d5d12781c1fdc',
    messagingSenderId: '704594678101',
    projectId: 'itinerarios-70663',
    storageBucket: 'itinerarios-70663.firebasestorage.app',
    iosBundleId: 'com.example.timeline',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBSfc_DRu5B6EDfNqXOUmmmsVy2vEtOs7o',
    appId: '1:704594678101:ios:0a5a74f10d5d12781c1fdc',
    messagingSenderId: '704594678101',
    projectId: 'itinerarios-70663',
    storageBucket: 'itinerarios-70663.firebasestorage.app',
    iosBundleId: 'com.example.timeline',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBmRFHYceQXtURTD2ATdGRimRDzYpw9NIc',
    appId: '1:704594678101:web:c38cfc5c069359aa1c1fdc',
    messagingSenderId: '704594678101',
    projectId: 'itinerarios-70663',
    authDomain: 'itinerarios-70663.firebaseapp.com',
    storageBucket: 'itinerarios-70663.firebasestorage.app',
    measurementId: 'G-Z7XT1NLVF7',
  );
}
