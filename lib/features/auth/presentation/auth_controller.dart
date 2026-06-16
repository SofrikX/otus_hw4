import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firebase_auth_repository.dart';
import '../domain/app_user.dart';

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._authRepository) : super(const AsyncValue.data(null));

  final AuthRepository _authRepository;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<void>(
      () async {
        await _authRepository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      },
    );
  }

  Future<void> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<void>(
      () async {
        await _authRepository.registerWithEmailAndPassword(
          email: email,
          password: password,
          displayName: displayName,
        );
      },
    );
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_authRepository.signOut);
  }
}
