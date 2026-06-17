import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/backend_config.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/pets/presentation/screens/pet_profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final config = ref.watch(backendConfigProvider);
  final authState = ref.watch(authStateProvider);
  final currentUser = authState.valueOrNull;

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthRoute =
          state.uri.path == '/login' || state.uri.path == '/register';
      final isAuthenticated = currentUser != null;

      if (!config.requiresAuth) {
        return null;
      }

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/pets/:petId',
        name: 'petProfile',
        builder: (context, state) {
          final petId = state.pathParameters['petId'] ?? '';
          return PetProfileScreen(petId: petId);
        },
      ),
    ],
  );
});
