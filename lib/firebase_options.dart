import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web — '
        'you can reconfigure for this platform in firebase_options.dart.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDIlFfsXxjKk9FhuOf1WhKVIKDQg0at5nU',
    appId: '1:62315311153:android:da88282179b3bad44c6510',
    messagingSenderId: '62315311153',
    projectId: 'kopri-908ad',
    storageBucket: 'kopri-908ad.firebasestorage.app',
  );
}
