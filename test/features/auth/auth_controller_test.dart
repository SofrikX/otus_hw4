import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petconnect/features/auth/domain/app_user.dart';
import 'package:petconnect/features/auth/domain/auth_repository.dart';
import 'package:petconnect/features/auth/presentation/auth_controller.dart';

void main() {
  test('signIn exposes loading and success states', () async {
    final repository = _FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(repository.dispose);

    final controller = container.read(authControllerProvider.notifier);
    final signInFuture = controller.signIn(
      email: 'owner@example.com',
      password: 'password',
    );

    expect(container.read(authControllerProvider).isLoading, isTrue);

    repository.completeSignIn(
      const AppUser(id: 'user-1', email: 'owner@example.com'),
    );
    await signInFuture;

    expect(container.read(authControllerProvider).hasValue, isTrue);
    expect(repository.lastSignInEmail, 'owner@example.com');
    expect(
        controller.currentUser,
        const AppUser(
          id: 'user-1',
          email: 'owner@example.com',
        ));
  });

  test('register exposes repository errors', () async {
    final repository = _FakeAuthRepository(
      registerError: const AuthFailure('Пользователь уже существует.'),
    );
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(repository.dispose);

    await container.read(authControllerProvider.notifier).register(
          email: 'owner@example.com',
          password: 'password',
          displayName: 'Алексей',
        );

    final state = container.read(authControllerProvider);
    expect(state.hasError, isTrue);
    expect(state.error.toString(), 'Пользователь уже существует.');
  });

  test('signInWithGoogle delegates to auth repository', () async {
    final repository = _FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(repository.dispose);

    await container.read(authControllerProvider.notifier).signInWithGoogle();

    expect(container.read(authControllerProvider).hasValue, isTrue);
    expect(repository.googleSignInCalls, 1);
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.registerError});

  final Object? registerError;
  final _authStateController = StreamController<AppUser?>.broadcast();
  final _signInCompleter = Completer<AppUser>();

  AppUser? _currentUser;
  String? lastSignInEmail;
  int googleSignInCalls = 0;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> authStateChanges() {
    return _authStateController.stream;
  }

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    lastSignInEmail = email;
    return _signInCompleter.future;
  }

  void completeSignIn(AppUser user) {
    _currentUser = user;
    _signInCompleter.complete(user);
    _authStateController.add(user);
  }

  @override
  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final error = registerError;
    if (error != null) {
      throw error;
    }

    final user = AppUser(id: 'user-2', email: email, displayName: displayName);
    _currentUser = user;
    _authStateController.add(user);
    return user;
  }

  @override
  Future<void> signInWithGoogle() async {
    googleSignInCalls += 1;
    final user = const AppUser(
      id: 'google-user',
      email: 'google.owner@example.com',
      displayName: 'Google Owner',
    );
    _currentUser = user;
    _authStateController.add(user);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authStateController.add(null);
  }

  Future<void> dispose() {
    return _authStateController.close();
  }
}
