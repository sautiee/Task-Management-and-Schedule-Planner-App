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
    apiKey: 'AIzaSyCAmwGJw39HB1aBpe6uM2VzzWVRCCZ83jg',
    appId: '1:440675859746:web:212d4e6ade3fc8d6d8397b',
    messagingSenderId: '440675859746',
    projectId: 'authlogin-97398',
    authDomain: 'authlogin-97398.firebaseapp.com',
    storageBucket: 'authlogin-97398.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAkwcbmF1xppRjuQDpCqm3UIRG6hAgxBxw',
    appId: '1:440675859746:android:ba0a38056eaf8c22d8397b',
    messagingSenderId: '440675859746',
    projectId: 'authlogin-97398',
    storageBucket: 'authlogin-97398.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCLIZFxY_iUSGIpY6R-Nze_pFa5mnqfj_E',
    appId: '1:440675859746:ios:637662b64e4d6163d8397b',
    messagingSenderId: '440675859746',
    projectId: 'authlogin-97398',
    storageBucket: 'authlogin-97398.firebasestorage.app',
    iosBundleId: 'com.example.testing',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCLIZFxY_iUSGIpY6R-Nze_pFa5mnqfj_E',
    appId: '1:440675859746:ios:be6bc902bc617a81d8397b',
    messagingSenderId: '440675859746',
    projectId: 'authlogin-97398',
    storageBucket: 'authlogin-97398.firebasestorage.app',
    iosBundleId: 'com.example.taskmanagement',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCAmwGJw39HB1aBpe6uM2VzzWVRCCZ83jg',
    appId: '1:440675859746:web:1c467d2bd43c5c21d8397b',
    messagingSenderId: '440675859746',
    projectId: 'authlogin-97398',
    authDomain: 'authlogin-97398.firebaseapp.com',
    storageBucket: 'authlogin-97398.firebasestorage.app',
  );
}
