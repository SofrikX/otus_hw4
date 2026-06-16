import '../../../core/network/api_client.dart';
import '../../../core/network/api_error.dart';
import '../domain/pet.dart';
import '../domain/pet_repository.dart';

class ApiPetRepository implements PetRepository {
  const ApiPetRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Pet?> getPetById(String petId) async {
    try {
      final pet = await _apiClient.getPet(petId);
      return _mapPet(pet);
    } on ApiNotFoundException {
      return null;
    }
  }

  @override
  Future<List<Pet>> getPetsByOwner(String ownerId) async {
    final pets = await _apiClient.getPetsByOwner(ownerId);
    return pets.map(_mapPet).toList(growable: false);
  }

  Pet _mapPet(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      name: json['name'] as String? ?? 'Питомец',
      animalType: json['animalType'] as String? ?? 'Питомец',
      breed: json['breed'] as String? ?? 'Не указана',
      age: (json['age'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      photoEmoji: json['photoEmoji'] as String? ?? '🐾',
      ownerName: json['ownerName'] as String? ?? 'Владелец',
    );
  }
}
