import 'pet.dart';

abstract class PetRepository {
  Future<Pet?> getPetById(String petId);

  Future<List<Pet>> getPetsByOwner(String ownerId);
}
