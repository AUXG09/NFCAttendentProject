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
    apiKey: 'AIzaSyBVmMhQ_KX6db_QFmLafQn5rAst7JPtvzE',
    appId: '1:678309963864:web:9992fc02f91f06e98a822d',
    messagingSenderId: '678309963864',
    projectId: 'cyattendance',
    authDomain: 'cyattendance.firebaseapp.com',
    databaseURL: 'https://cyattendance-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'cyattendance.appspot.com',
    measurementId: 'G-LXNPL481EP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB5aCx1S4KM3zowTtvTV3FibEf_pSSALYs',
    appId: '1:977224384146:android:67d94b5441f2a3dc74b04b',
    messagingSenderId: '977224384146',
    projectId: 'cp422021-tharadol',
    databaseURL: 'https://cp422021-tharadol-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'cp422021-tharadol.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyALnNcC6lS3GQAPL339hV2YsHabrFpKVag',
    appId: '1:977224384146:ios:0cfc1aa5f4dc922e74b04b',
    messagingSenderId: '977224384146',
    projectId: 'cp422021-tharadol',
    databaseURL: 'https://cp422021-tharadol-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'cp422021-tharadol.appspot.com',
    androidClientId: '977224384146-fq44b2kt2ri0de43kun1trhodmpjvcm3.apps.googleusercontent.com',
    iosClientId: '977224384146-oe1i1vhm99etk2r3dn56orj63d66qkmj.apps.googleusercontent.com',
    iosBundleId: 'com.example.nfcCheckAttendance',
  );

}