import '../../../core/network/api_client.dart';
import '../../../core/network/api_error.dart';
import '../domain/pet.dart';
import '../domain/pet_repository.dart';

class ApiPetRepository implements PetRepository {
  const ApiPetRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Pet>> fetchPets({int limit = 50}) async {
    final pets = await _apiClient.getPets(limit: limit);
    return pets.map(_mapPet).toList(growable: false);
  }

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

  @override
  Future<Pet> createPet(CreatePetInput input) async {
    final pet = await _apiClient.createPet({
      'ownerId': input.ownerId,
      'ownerName': input.ownerName,
      'name': input.name,
      'animalType': input.animalType,
      'breed': input.breed,
      'age': input.age,
      'description': input.description,
      'photoEmoji': input.photoEmoji,
      'photoUrl': null,
    });

    return _mapPet(pet);
  }

  @override
  Future<Pet> updatePet(UpdatePetInput input) async {
    final pet = await _apiClient.updatePet(input.petId, {
      'name': input.name,
      'animalType': input.animalType,
      'breed': input.breed,
      'age': input.age,
      'description': input.description,
      'photoEmoji': input.photoEmoji,
    });

    return _mapPet(pet);
  }

  @override
  Future<void> deletePet(String petId) {
    return _apiClient.deletePet(petId);
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
      photoUrl: json['photoUrl'] as String?,
      photoEmoji: json['photoEmoji'] as String? ?? '🐾',
      ownerName: json['ownerName'] as String? ?? 'Владелец',
    );
  }

  @override
  Future<Pet> uploadPetPhoto(UploadPetPhotoInput input) {
    throw const ApiUnexpectedException(
      statusCode: 501,
      code: 'unsupported-storage-backend',
      message: 'Pet photo upload is available in Supabase backend mode.',
    );
  }
}
