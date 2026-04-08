import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'your-web-api-key',
        appId: 'your-web-app-id',
        messagingSenderId: 'your-sender-id',
        projectId: 'your-project-id',
        authDomain: 'your-project.firebaseapp.com',
        storageBucket: 'your-project.firebasestorage.app',
        measurementId: 'your-measurement-id',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'your-android-api-key',
          appId: 'your-android-app-id',
          messagingSenderId: 'your-sender-id',
          projectId: 'your-project-id',
          storageBucket: 'your-project.firebasestorage.app',
        );
      case TargetPlatform.iOS:
        return const FirebaseOptions(
          apiKey: 'your-ios-api-key',
          appId: 'your-ios-app-id',
          messagingSenderId: 'your-sender-id',
          projectId: 'your-project-id',
          storageBucket: 'your-project.firebasestorage.app',
          iosBundleId: 'com.example.eventManager',
        );
      case TargetPlatform.macOS:
        return const FirebaseOptions(
          apiKey: 'your-macos-api-key',
          appId: 'your-macos-app-id',
          messagingSenderId: 'your-sender-id',
          projectId: 'your-project-id',
          storageBucket: 'your-project.firebasestorage.app',
          iosBundleId: 'com.example.eventManager',
        );
      case TargetPlatform.windows:
        return const FirebaseOptions(
          apiKey: 'your-windows-api-key',
          appId: 'your-windows-app-id',
          messagingSenderId: 'your-sender-id',
          projectId: 'your-project-id',
          authDomain: 'your-project.firebaseapp.com',
          storageBucket: 'your-project.firebasestorage.app',
          measurementId: 'your-measurement-id',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}
