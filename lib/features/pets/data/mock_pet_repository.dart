import '../../../core/data/mock_data.dart';
import '../domain/pet.dart';
import '../domain/pet_repository.dart';

class MockPetRepository implements PetRepository {
  MockPetRepository({List<Pet>? initialPets})
      : _pets = List<Pet>.unmodifiable(initialPets ?? mockPets);

  final List<Pet> _pets;

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

  Future<List<Pet>> getAllPets() async {
    return _pets;
  }
}
