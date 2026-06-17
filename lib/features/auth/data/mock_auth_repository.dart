import 'dart:async';

import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository({
    AppUser? initialUser = const AppUser(
      id: 'mock-user',
      email: 'owner@example.test',
      displayName: 'Demo Owner',
    ),
  }) : _currentUser = initialUser {
    _authStateController.add(_currentUser);
  }

  final _authStateController = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _currentUser;
    yield* _authStateController.stream;
  }

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final user = AppUser(
      id: 'mock-user',
      email: email.trim(),
      displayName: 'Demo Owner',
    );
    _setCurrentUser(user);
    return user;
  }

  @override
  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final trimmedName = displayName?.trim();
    final user = AppUser(
      id: 'mock-user',
      email: email.trim(),
      displayName: trimmedName == null || trimmedName.isEmpty
          ? 'Demo Owner'
          : trimmedName,
    );
    _setCurrentUser(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    _setCurrentUser(null);
  }

  void _setCurrentUser(AppUser? user) {
    _currentUser = user;
    if (!_authStateController.isClosed) {
      _authStateController.add(user);
    }
  }

  Future<void> dispose() {
    return _authStateController.close();
  }
}
