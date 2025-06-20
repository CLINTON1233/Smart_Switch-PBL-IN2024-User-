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
    apiKey: 'AIzaSyChanXgxaGPzSSv_zML9iAcldjdot5aIsQ',
    appId: '1:267223687057:web:2cb7ffe2a63460e7f58430',
    messagingSenderId: '267223687057',
    projectId: 'smart-switch-pblin2024',
    authDomain: 'smart-switch-pblin2024.firebaseapp.com',
    storageBucket: 'smart-switch-pblin2024.firebasestorage.app',
    measurementId: 'G-F9ZEZPWGH7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD-V8vjhdCFMOo6_rEuVg8UEYiVv0qFWfk',
    appId: '1:267223687057:android:ce141009941456f5f58430',
    messagingSenderId: '267223687057',
    projectId: 'smart-switch-pblin2024',
    storageBucket: 'smart-switch-pblin2024.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBaNkaLSTE5g-wfJtOlXppwew-9xqOSuGg',
    appId: '1:267223687057:ios:f68731c57688f4cbf58430',
    messagingSenderId: '267223687057',
    projectId: 'smart-switch-pblin2024',
    storageBucket: 'smart-switch-pblin2024.firebasestorage.app',
    iosBundleId: 'com.example.smartSwitch',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBaNkaLSTE5g-wfJtOlXppwew-9xqOSuGg',
    appId: '1:267223687057:ios:f68731c57688f4cbf58430',
    messagingSenderId: '267223687057',
    projectId: 'smart-switch-pblin2024',
    storageBucket: 'smart-switch-pblin2024.firebasestorage.app',
    iosBundleId: 'com.example.smartSwitch',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyChanXgxaGPzSSv_zML9iAcldjdot5aIsQ',
    appId: '1:267223687057:web:ccdbe1cffd379ecdf58430',
    messagingSenderId: '267223687057',
    projectId: 'smart-switch-pblin2024',
    authDomain: 'smart-switch-pblin2024.firebaseapp.com',
    storageBucket: 'smart-switch-pblin2024.firebasestorage.app',
    measurementId: 'G-93W7NR9XE0',
  );
}
