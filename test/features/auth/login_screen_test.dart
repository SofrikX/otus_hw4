import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petconnect/features/auth/domain/app_user.dart';
import 'package:petconnect/features/auth/domain/auth_repository.dart';
import 'package:petconnect/features/auth/presentation/auth_controller.dart';
import 'package:petconnect/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('LoginScreen shows Google OAuth button', (tester) async {
    await tester.pumpWidget(_buildLogin(_FakeAuthRepository()));

    expect(find.byKey(const Key('login-google')), findsOneWidget);
    expect(find.text('Войти через Google'), findsOneWidget);
  });

  testWidgets('LoginScreen validates email and password before submit',
      (tester) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_buildLogin(repository));

    await tester.enterText(find.byKey(const Key('login-email')), 'broken');
    await tester.enterText(find.byKey(const Key('login-password')), '123');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Проверьте email'), findsOneWidget);
    expect(find.text('Минимум 6 символов'), findsOneWidget);
    expect(repository.signInCalls, 0);
  });

  testWidgets('LoginScreen shows loading state while signing in',
      (tester) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_buildLogin(repository));

    await tester.enterText(
      find.byKey(const Key('login-email')),
      'owner@example.test',
    );
    await tester.enterText(find.byKey(const Key('login-password')), 'password');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('login-submit')))
            .onPressed,
        isNull);

    repository.completeSignIn(
      const AppUser(id: 'user-1', email: 'owner@example.test'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('LoginScreen shows friendly auth error', (tester) async {
    final repository = _FakeAuthRepository(
      signInError: const AuthFailure('Email или пароль не подошли.'),
    );
    await tester.pumpWidget(_buildLogin(repository));

    await tester.enterText(
      find.byKey(const Key('login-email')),
      'owner@example.test',
    );
    await tester.enterText(find.byKey(const Key('login-password')), 'password');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Email или пароль не подошли.'), findsOneWidget);
  });

  testWidgets('LoginScreen shows Google OAuth error', (tester) async {
    final repository = _FakeAuthRepository(
      googleSignInError: const AuthFailure(
        'Не удалось открыть вход через Google. Попробуйте еще раз.',
      ),
    );
    await tester.pumpWidget(_buildLogin(repository));

    await tester.tap(find.byKey(const Key('login-google')));
    await tester.pumpAndSettle();

    expect(
      find.text('Не удалось открыть вход через Google. Попробуйте еще раз.'),
      findsOneWidget,
    );
    expect(repository.googleSignInCalls, 1);
  });
}

Widget _buildLogin(_FakeAuthRepository repository) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
    ],
    child: const MaterialApp(home: LoginScreen()),
  );
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.signInError, this.googleSignInError});

  final Object? signInError;
  final Object? googleSignInError;
  final _authStateController = StreamController<AppUser?>.broadcast();
  final _signInCompleter = Completer<AppUser>();

  AppUser? _currentUser;
  int signInCalls = 0;
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
  }) async {
    signInCalls += 1;
    final error = signInError;
    if (error != null) {
      throw error;
    }

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
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signInWithGoogle() async {
    googleSignInCalls += 1;
    final error = googleSignInError;
    if (error != null) {
      throw error;
    }

    final user = const AppUser(
      id: 'google-user',
      email: 'google.owner@example.test',
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
}
