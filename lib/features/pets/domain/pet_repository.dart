import 'pet.dart';

abstract class PetRepository {
  Future<List<Pet>> fetchPets({int limit = 50});

  Future<Pet?> getPetById(String petId);

  Future<List<Pet>> getPetsByOwner(String ownerId);

  Future<Pet> createPet(CreatePetInput input);
}

class CreatePetInput {
  const CreatePetInput({
    required this.ownerId,
    required this.name,
    required this.animalType,
    required this.breed,
    required this.age,
    required this.description,
    this.ownerName,
    this.photoEmoji,
  });

  final String ownerId;
  final String name;
  final String animalType;
  final String breed;
  final int age;
  final String description;
  final String? ownerName;
  final String? photoEmoji;
}
