import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/pets/presentation/screens/pet_profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
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
