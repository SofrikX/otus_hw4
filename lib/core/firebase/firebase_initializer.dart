import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

const _useAuthEmulator = bool.fromEnvironment(
  'USE_FIREBASE_AUTH_EMULATOR',
);

const _authEmulatorHost = String.fromEnvironment(
  'FIREBASE_AUTH_EMULATOR_HOST',
  defaultValue: '127.0.0.1',
);

const _authEmulatorPort = int.fromEnvironment(
  'FIREBASE_AUTH_EMULATOR_PORT',
  defaultValue: 9099,
);

const _firebaseProjectId = String.fromEnvironment(
  'FIREBASE_PROJECT_ID',
  defaultValue: 'demo-petconnect',
);

const _firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
const _firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
const _firebaseMessagingSenderId = String.fromEnvironment(
  'FIREBASE_MESSAGING_SENDER_ID',
);
const _firebaseAuthDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
const _firebaseStorageBucket = String.fromEnvironment(
  'FIREBASE_STORAGE_BUCKET',
);

Future<void> initializeFirebaseApp() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: _firebaseOptions);
  }

  if (_useAuthEmulator) {
    await FirebaseAuth.instance.useAuthEmulator(
      _authEmulatorHost,
      _authEmulatorPort,
    );
  }
}

FirebaseOptions? get _firebaseOptions {
  if (_hasDartDefineFirebaseOptions) {
    return FirebaseOptions(
      apiKey: _firebaseApiKey,
      appId: _firebaseAppId,
      messagingSenderId: _firebaseMessagingSenderId,
      projectId: _firebaseProjectId,
      authDomain: _firebaseAuthDomain,
      storageBucket: _firebaseStorageBucket,
    );
  }

  if (_useAuthEmulator) {
    return FirebaseOptions(
      apiKey: 'demo-api-key',
      appId: '1:1234567890:web:petconnect',
      messagingSenderId: '1234567890',
      projectId: _firebaseProjectId,
      authDomain: '$_firebaseProjectId.firebaseapp.com',
      storageBucket: '$_firebaseProjectId.appspot.com',
    );
  }

  return null;
}

bool get _hasDartDefineFirebaseOptions {
  return _firebaseApiKey.isNotEmpty &&
      _firebaseAppId.isNotEmpty &&
      _firebaseMessagingSenderId.isNotEmpty &&
      _firebaseProjectId.isNotEmpty;
}
