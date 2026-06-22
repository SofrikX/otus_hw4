import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:petconnect/core/data/mock_data.dart';
import 'package:petconnect/core/network/api_error.dart';
import 'package:petconnect/features/pets/application/pets_provider.dart';
import 'package:petconnect/features/pets/domain/pet.dart';
import 'package:petconnect/features/pets/domain/pet_repository.dart';
import 'package:petconnect/features/pets/presentation/screens/pet_profile_screen.dart';
import 'package:petconnect/features/pets/presentation/screens/pets_screen.dart';

void main() {
  testWidgets('PetsScreen shows mock pets list', (tester) async {
    await tester.pumpWidget(_buildPetsApp());
    await tester.pumpAndSettle();

    expect(find.text(mockPets[0].name), findsOneWidget);
    expect(find.text(mockPets[1].name), findsOneWidget);
    expect(find.text(mockPets[2].name), findsOneWidget);
  });

  testWidgets('PetsScreen opens pet profile through go_router', (tester) async {
    final pet = mockPets.first;

    await tester.pumpWidget(_buildPetsApp());
    await tester.pumpAndSettle();

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

  testWidgets('PetProfileScreen shows pet profile success', (tester) async {
    final pet = mockPets.first;

    await tester.pumpWidget(
      _buildPetsApp(
        initialLocation: '/pets/${pet.id}',
        repository: _FakePetRepository(pets: [pet]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Профиль питомца'), findsOneWidget);
    expect(find.text(pet.name), findsOneWidget);
    expect(find.text(pet.ownerName), findsOneWidget);
    expect(find.text(pet.description), findsOneWidget);
  });

  testWidgets('PetProfileScreen shows placeholder when pet has no photo',
      (tester) async {
    final pet = mockPets.first.copyWith(photoUrl: null);

    await tester.pumpWidget(
      _buildPetsApp(
        initialLocation: '/pets/${pet.id}',
        repository: _FakePetRepository(pets: [pet]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(pet.photoEmoji), findsWidgets);
  });

  testWidgets('PetProfileScreen renders network image when photoUrl exists',
      (tester) async {
    final pet = mockPets.first.copyWith(
      photoUrl: 'https://example.test/pet-images/bruno.jpg',
    );

    await tester.pumpWidget(
      _buildPetsApp(
        initialLocation: '/pets/${pet.id}',
        repository: _FakePetRepository(pets: [pet]),
      ),
    );
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('PetProfileScreen shows not found state for unknown pet',
      (tester) async {
    await tester.pumpWidget(
      _buildPetsApp(
        initialLocation: '/pets/unknown-pet',
        repository: _FakePetRepository(pets: const []),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Питомец не найден'), findsOneWidget);
    expect(
      find.text('Проверьте ссылку или вернитесь к списку питомцев.'),
      findsOneWidget,
    );
  });

  testWidgets('PetProfileScreen shows backend error state', (tester) async {
    await tester.pumpWidget(
      _buildPetsApp(
        initialLocation: '/pets/pet-1',
        repository: _FakePetRepository(
          error: const ApiServerException(
            message: 'Supabase временно недоступен.',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Не удалось загрузить данные'), findsOneWidget);
    expect(find.text('Сервер временно недоступен. Попробуйте позже.'),
        findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
  });
}

Widget _buildPetsApp({
  String initialLocation = '/',
  PetRepository? repository,
}) {
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
    overrides: [
      if (repository != null)
        petRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

class _FakePetRepository implements PetRepository {
  const _FakePetRepository({
    this.pets = const [],
    this.error,
  });

  final List<Pet> pets;
  final Object? error;

  @override
  Future<List<Pet>> fetchPets({int limit = 50}) async {
    final error = this.error;
    if (error != null) {
      throw error;
    }

    return pets.take(limit).toList(growable: false);
  }

  @override
  Future<Pet?> getPetById(String petId) async {
    final error = this.error;
    if (error != null) {
      throw error;
    }

    for (final pet in pets) {
      if (pet.id == petId) {
        return pet;
      }
    }

    return null;
  }

  @override
  Future<List<Pet>> getPetsByOwner(String ownerId) async {
    final error = this.error;
    if (error != null) {
      throw error;
    }

    return pets.where((pet) => pet.ownerId == ownerId).toList(growable: false);
  }

  @override
  Future<Pet> createPet(CreatePetInput input) async {
    final error = this.error;
    if (error != null) {
      throw error;
    }

    return Pet(
      id: 'created-pet',
      ownerId: input.ownerId,
      name: input.name,
      animalType: input.animalType,
      breed: input.breed,
      age: input.age,
      description: input.description,
      photoUrl: null,
      photoEmoji: input.photoEmoji ?? '🐾',
      ownerName: input.ownerName ?? 'Владелец',
    );
  }

  @override
  Future<Pet> uploadPetPhoto(UploadPetPhotoInput input) async {
    final error = this.error;
    if (error != null) {
      throw error;
    }

    final pet = await getPetById(input.petId);
    if (pet == null) {
      throw StateError('Pet not found.');
    }

    return pet.copyWith(photoUrl: 'https://example.test/${input.fileName}');
  }
}
