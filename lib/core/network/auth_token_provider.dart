import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AuthTokenProvider {
  Future<String?> getToken();
}

final authTokenProvider = Provider<AuthTokenProvider>((ref) {
  return FirebaseAuthTokenProvider(FirebaseAuth.instance);
});

class FirebaseAuthTokenProvider implements AuthTokenProvider {
  const FirebaseAuthTokenProvider(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  Future<String?> getToken() {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return Future<String?>.value();
    }

    return user.getIdToken();
  }
}
