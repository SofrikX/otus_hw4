import 'package:firebase_auth/firebase_auth.dart';

import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  const FirebaseAuthRepository(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  AppUser? get currentUser => _mapFirebaseUser(_firebaseAuth.currentUser);

  @override
  Stream<AppUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = _mapRequiredUser(credential.user);
      return user;
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_friendlyFirebaseAuthMessage(error));
    }
  }

  @override
  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final trimmedDisplayName = displayName?.trim();
      if (trimmedDisplayName != null && trimmedDisplayName.isNotEmpty) {
        await credential.user?.updateDisplayName(trimmedDisplayName);
      }

      final user = _mapRequiredUser(_firebaseAuth.currentUser);
      return user;
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_friendlyFirebaseAuthMessage(error));
    }
  }

  @override
  Future<void> signInWithGoogle() {
    throw const AuthFailure(
      'Вход через Google настроен через Supabase Auth.',
    );
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  AppUser _mapRequiredUser(User? user) {
    final mappedUser = _mapFirebaseUser(user);
    if (mappedUser == null) {
      throw const AuthFailure('Не удалось получить пользователя.');
    }

    return mappedUser;
  }

  AppUser? _mapFirebaseUser(User? user) {
    if (user == null) {
      return null;
    }

    return AppUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }

  String _friendlyFirebaseAuthMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Проверьте формат email.';
      case 'user-disabled':
        return 'Этот аккаунт отключен.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email или пароль не подошли.';
      case 'email-already-in-use':
        return 'Пользователь с таким email уже есть.';
      case 'weak-password':
        return 'Пароль должен быть надежнее.';
      case 'network-request-failed':
        return 'Нет соединения с сервисом авторизации.';
      default:
        return 'Не удалось выполнить вход. Попробуйте еще раз.';
    }
  }
}
