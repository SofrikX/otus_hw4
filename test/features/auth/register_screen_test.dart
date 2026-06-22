import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petconnect/features/auth/domain/app_user.dart';
import 'package:petconnect/features/auth/domain/auth_repository.dart';
import 'package:petconnect/features/auth/presentation/auth_controller.dart';
import 'package:petconnect/features/auth/presentation/register_screen.dart';

void main() {
  testWidgets('RegisterScreen validates email and password before submit',
      (tester) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_buildRegister(repository));

    await tester.enterText(find.byKey(const Key('register-email')), 'broken');
    await tester.enterText(find.byKey(const Key('register-password')), '123');
    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Проверьте email'), findsOneWidget);
    expect(find.text('Минимум 6 символов'), findsOneWidget);
    expect(repository.registerCalls, 0);
  });

  testWidgets('RegisterScreen sends trimmed display name to auth controller',
      (tester) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_buildRegister(repository));

    await tester.enterText(find.byKey(const Key('register-name')), '  Алиса ');
    await tester.enterText(
      find.byKey(const Key('register-email')),
      'owner@example.test',
    );
    await tester.enterText(
      find.byKey(const Key('register-password')),
      'password123',
    );
    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pumpAndSettle();

    expect(repository.registerCalls, 1);
    expect(repository.lastDisplayName, 'Алиса');
  });
}

Widget _buildRegister(_FakeAuthRepository repository) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
    ],
    child: const MaterialApp(home: RegisterScreen()),
  );
}

class _FakeAuthRepository implements AuthRepository {
  final _authStateController = StreamController<AppUser?>.broadcast();

  AppUser? _currentUser;
  int registerCalls = 0;
  String? lastDisplayName;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> authStateChanges() => _authStateController.stream;

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    registerCalls += 1;
    lastDisplayName = displayName;
    final user = AppUser(
      id: 'user-1',
      email: email,
      displayName: displayName,
    );
    _currentUser = user;
    _authStateController.add(user);
    return user;
  }

  @override
  Future<void> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authStateController.add(null);
  }
}
