import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petconnect/app/router.dart';
import 'package:petconnect/core/config/backend_config.dart';
import 'package:petconnect/features/auth/domain/app_user.dart';
import 'package:petconnect/features/auth/domain/auth_repository.dart';
import 'package:petconnect/features/auth/presentation/auth_controller.dart';
import 'package:petconnect/features/auth/presentation/login_screen.dart';
import 'package:petconnect/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('Supabase backend redirects anonymous users to login',
      (tester) async {
    await tester.pumpWidget(
      _buildRouter(
        config: const BackendConfig(
          baseUrl: '',
          useSupabaseBackend: true,
          supabaseUrl: 'http://127.0.0.1:54321',
          supabasePublishableKey: 'test-publishable-key',
        ),
        repository: _FakeAuthRepository(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('mock mode keeps protected screens available without login',
      (tester) async {
    await tester.pumpWidget(
      _buildRouter(
        config: const BackendConfig(baseUrl: ''),
        repository: _FakeAuthRepository(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });
}

Widget _buildRouter({
  required BackendConfig config,
  required AuthRepository repository,
}) {
  return ProviderScope(
    overrides: [
      backendConfigProvider.overrideWithValue(config),
      authRepositoryProvider.overrideWithValue(repository),
    ],
    child: Consumer(
      builder: (context, ref, child) {
        return MaterialApp.router(
          routerConfig: ref.watch(appRouterProvider),
        );
      },
    ),
  );
}

class _FakeAuthRepository implements AuthRepository {
  final _authStateController = StreamController<AppUser?>.broadcast();

  @override
  AppUser? get currentUser => null;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield null;
    yield* _authStateController.stream;
  }

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
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    _authStateController.add(null);
  }
}
