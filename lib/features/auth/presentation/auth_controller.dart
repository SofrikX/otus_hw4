import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../../core/config/backend_config.dart';
import '../../../core/logging/app_logger.dart';
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
    AppLogger logger = const AppLogger(component: 'auth'),
  })  : _analytics = analytics,
        _logger = logger,
        super(const AsyncValue.data(null));

  final AuthRepository _authRepository;
  final AnalyticsService? _analytics;
  final AppLogger _logger;

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
      _logger.info(
        'auth_success',
        message: 'Authentication succeeded.',
        details: const {
          'operation': 'sign_in',
          'method': 'email',
        },
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      await _analytics?.trackAuthError(operation: 'sign_in', error: error);
      _logAuthFailure(
        operation: 'sign_in',
        method: 'email',
        error: error,
      );
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
        displayName: displayName?.trim(),
      );
      await _analytics?.track(
        AnalyticsEvent.signInSuccess,
        params: const {'method': 'email_after_signup'},
      );
      _logger.info(
        'auth_success',
        message: 'Authentication succeeded.',
        details: const {
          'operation': 'sign_up',
          'method': 'email_after_signup',
        },
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      await _analytics?.trackAuthError(operation: 'sign_up', error: error);
      _logAuthFailure(
        operation: 'sign_up',
        method: 'email',
        error: error,
      );
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
      _logger.info(
        'auth_success',
        message: 'Authentication succeeded.',
        details: const {
          'operation': 'sign_in_google',
          'method': 'google',
        },
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      await _analytics?.trackAuthError(
        operation: 'sign_in_google',
        error: error,
      );
      _logAuthFailure(
        operation: 'sign_in_google',
        method: 'google',
        error: error,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_authRepository.signOut);
  }

  void _logAuthFailure({
    required String operation,
    required String method,
    required Object error,
  }) {
    _logger.warning(
      'auth_failure',
      message: 'Authentication failed.',
      details: {
        'operation': operation,
        'method': method,
        'error_type': error.runtimeType.toString(),
      },
    );
  }
}
