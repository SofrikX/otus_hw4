import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petconnect/features/auth/domain/app_user.dart';
import 'package:petconnect/features/pets/application/pets_provider.dart';
import 'package:petconnect/features/pets/domain/pet.dart';
import 'package:petconnect/features/pets/domain/pet_repository.dart';

void main() {
  test('createPet validates, trims and normalizes pet form fields', () async {
    final repository = _FakePetRepository();
    final container = ProviderContainer(
      overrides: [
        petRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final pet = await container.read(petActionsProvider).createPet(
          owner: const AppUser(
            id: 'owner-1',
            email: 'owner@example.test',
            displayName: 'Owner',
          ),
          name: '  Луна  ',
          animalType: ' CAT ',
          breed: '  Метис  ',
          ageText: ' 3 ',
          description: '  Любит играть.  ',
        );

    expect(pet.name, 'Луна');
    expect(repository.lastCreateInput?.animalType, 'cat');
    expect(repository.lastCreateInput?.breed, 'Метис');
    expect(repository.lastCreateInput?.age, 3);
    expect(repository.lastCreateInput?.description, 'Любит играть.');
  });

  test('createPet rejects invalid age before repository call', () async {
    final repository = _FakePetRepository();
    final container = ProviderContainer(
      overrides: [
        petRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(petActionsProvider).createPet(
            owner: const AppUser(id: 'owner-1', email: 'owner@example.test'),
            name: 'Луна',
            animalType: 'dog',
            breed: 'Такса',
            ageText: '31',
            description: 'Любит прогулки.',
          ),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          'Возраст должен быть числом от 0 до 30.',
        ),
      ),
    );

    expect(repository.createCalls, 0);
  });

  test(
      'updatePet and deletePet reject non-owner actions before repository call',
      () async {
    final repository = _FakePetRepository();
    final container = ProviderContainer(
      overrides: [
        petRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    const pet = Pet(
      id: 'pet-1',
      ownerId: 'owner-1',
      name: 'Бруно',
      animalType: 'dog',
      breed: 'Корги',
      age: 4,
      description: 'Очень дружелюбный.',
      photoEmoji: '🐶',
      ownerName: 'Owner',
    );
    const otherUser = AppUser(id: 'owner-2', email: 'other@example.test');

    await expectLater(
      container.read(petActionsProvider).updatePet(
            pet: pet,
            owner: otherUser,
            name: 'Бруно',
            animalType: 'dog',
            breed: 'Корги',
            ageText: '4',
            description: 'Очень дружелюбный.',
          ),
      throwsA(isA<ArgumentError>()),
    );
    await expectLater(
      container.read(petActionsProvider).deletePet(
            pet: pet,
            owner: otherUser,
          ),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.updateCalls, 0);
    expect(repository.deleteCalls, 0);
  });
}

class _FakePetRepository implements PetRepository {
  CreatePetInput? lastCreateInput;
  int createCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;

  @override
  Future<List<Pet>> fetchPets({int limit = 50}) async => const [];

  @override
  Future<Pet?> getPetById(String petId) async => null;

  @override
  Future<List<Pet>> getPetsByOwner(String ownerId) async => const [];

  @override
  Future<Pet> createPet(CreatePetInput input) async {
    createCalls += 1;
    lastCreateInput = input;
    return Pet(
      id: 'created-pet',
      ownerId: input.ownerId,
      name: input.name,
      animalType: input.animalType,
      breed: input.breed,
      age: input.age,
      description: input.description,
      photoEmoji: input.photoEmoji ?? '🐾',
      ownerName: input.ownerName ?? 'Owner',
    );
  }

  @override
  Future<Pet> updatePet(UpdatePetInput input) async {
    updateCalls += 1;
    return Pet(
      id: input.petId,
      ownerId: 'owner-1',
      name: input.name,
      animalType: input.animalType,
      breed: input.breed,
      age: input.age,
      description: input.description,
      photoEmoji: input.photoEmoji ?? '🐾',
      ownerName: 'Owner',
    );
  }

  @override
  Future<void> deletePet(String petId) async {
    deleteCalls += 1;
  }

  @override
  Future<Pet> uploadPetPhoto(UploadPetPhotoInput input) {
    throw UnimplementedError();
  }
}
