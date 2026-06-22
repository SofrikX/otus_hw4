import '../../../core/data/mock_data.dart';
import '../domain/pet.dart';
import '../domain/pet_repository.dart';

class MockPetRepository implements PetRepository {
  MockPetRepository({List<Pet>? initialPets})
      : _pets = List<Pet>.of(initialPets ?? mockPets);

  final List<Pet> _pets;

  @override
  Future<List<Pet>> fetchPets({int limit = 50}) async {
    return _pets.take(limit).toList(growable: false);
  }

  @override
  Future<Pet?> getPetById(String petId) async {
    for (final pet in _pets) {
      if (pet.id == petId) {
        return pet;
      }
    }

    return null;
  }

  @override
  Future<List<Pet>> getPetsByOwner(String ownerId) async {
    return _pets.where((pet) => pet.ownerId == ownerId).toList(growable: false);
  }

  @override
  Future<Pet> createPet(CreatePetInput input) async {
    final pet = Pet(
      id: 'pet-${_pets.length + 1}',
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

    _pets.insert(0, pet);
    return pet;
  }

  Future<List<Pet>> getAllPets() async {
    return List<Pet>.unmodifiable(_pets);
  }

  @override
  Future<Pet> uploadPetPhoto(UploadPetPhotoInput input) async {
    final index = _pets.indexWhere((pet) => pet.id == input.petId);
    if (index == -1) {
      throw StateError('Pet not found.');
    }

    final updated = _pets[index].copyWith(
      photoUrl: 'https://example.test/pet-images/${input.petId}.jpg',
    );
    _pets[index] = updated;
    return updated;
  }
}
