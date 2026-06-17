import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/backend_config.dart';

abstract class AuthTokenProvider {
  Future<String?> getToken();
}

final authTokenProvider = Provider<AuthTokenProvider>((ref) {
  final config = ref.watch(backendConfigProvider);
  if (config.useSupabaseBackend) {
    return SupabaseAuthTokenProvider(Supabase.instance.client);
  }

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

class SupabaseAuthTokenProvider implements AuthTokenProvider {
  const SupabaseAuthTokenProvider(this._client);

  final SupabaseClient _client;

  @override
  Future<String?> getToken() {
    return Future<String?>.value(_client.auth.currentSession?.accessToken);
  }
}
