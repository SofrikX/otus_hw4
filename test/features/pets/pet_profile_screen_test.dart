import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:petconnect/core/data/mock_data.dart';
import 'package:petconnect/features/pets/presentation/screens/pet_profile_screen.dart';
import 'package:petconnect/features/pets/presentation/screens/pets_screen.dart';

void main() {
  testWidgets('PetsScreen shows mock pets list', (tester) async {
    await tester.pumpWidget(_buildPetsApp());

    expect(find.text(mockPets[0].name), findsOneWidget);
    expect(find.text(mockPets[1].name), findsOneWidget);
    expect(find.text(mockPets[2].name), findsOneWidget);
  });

  testWidgets('PetsScreen opens pet profile through go_router', (tester) async {
    final pet = mockPets.first;

    await tester.pumpWidget(_buildPetsApp());

    await tester.tap(find.text(pet.name));
    await tester.pumpAndSettle();

    expect(find.text('Профиль питомца'), findsOneWidget);
    expect(find.text(pet.name), findsOneWidget);
    expect(find.text(pet.ownerName), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Профиль питомца'), findsNothing);
    expect(find.text(mockPets[0].name), findsOneWidget);
  });

  testWidgets('PetProfileScreen shows not found state for unknown pet',
      (tester) async {
    await tester
        .pumpWidget(_buildPetsApp(initialLocation: '/pets/unknown-pet'));

    expect(find.text('Питомец не найден'), findsOneWidget);
    expect(
      find.text('Проверьте ссылку или вернитесь к списку питомцев.'),
      findsOneWidget,
    );
  });
}

Widget _buildPetsApp({String initialLocation = '/'}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(body: PetsScreen()),
      ),
      GoRoute(
        path: '/pets/:petId',
        builder: (context, state) {
          final petId = state.pathParameters['petId'] ?? '';
          return PetProfileScreen(petId: petId);
        },
      ),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(routerConfig: router),
  );
}
