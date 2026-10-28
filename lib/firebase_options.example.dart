// Example Firebase options with fake values.
// Copy this file to lib/firebase_options.dart (that file is in .gitignore).
// The app builds and runs with these values, but Crashlytics does not work.
// To use your own Firebase project, run `flutterfire configure` instead.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
    apiKey: 'AFakeKeyForLocalBuilds00000000000000000',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'kopri-example',
  );
}
