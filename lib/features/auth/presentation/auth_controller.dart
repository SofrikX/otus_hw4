import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../../core/config/backend_config.dart';
import '../data/firebase_auth_repository.dart';
import '../data/mock_auth_repository.dart';
import '../data/supabase_auth_repository.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final config = ref.watch(backendConfigProvider);

  if (config.useSupabaseBackend) {
    return SupabaseAuthRepository(
      Supabase.instance.client,
      redirectTo: config.supabaseAuthRedirectUri,
    );
  }

  if (config.useFirebaseBackend) {
    return FirebaseAuthRepository(FirebaseAuth.instance);
  }

  final repository = MockAuthRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(
    ref.watch(authRepositoryProvider),
    analytics: ref.watch(analyticsServiceProvider),
  );
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(
    this._authRepository, {
    AnalyticsService? analytics,
  })  : _analytics = analytics,
        super(const AsyncValue.data(null));

  final AuthRepository _authRepository;
  final AnalyticsService? _analytics;

  AppUser? get currentUser => _authRepository.currentUser;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _analytics?.track(
        AnalyticsEvent.signInSuccess,
        params: const {'method': 'email'},
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      await _analytics?.trackAuthError(operation: 'sign_in', error: error);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncValue.loading();
    await _analytics?.track(AnalyticsEvent.signUpStarted);
    try {
      await _authRepository.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      await _analytics?.track(
        AnalyticsEvent.signInSuccess,
        params: const {'method': 'email_after_signup'},
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      await _analytics?.trackAuthError(operation: 'sign_up', error: error);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signInWithGoogle();
      await _analytics?.track(
        AnalyticsEvent.signInSuccess,
        params: const {'method': 'google'},
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      await _analytics?.trackAuthError(
        operation: 'sign_in_google',
        error: error,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_authRepository.signOut);
  }
}
