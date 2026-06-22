import 'dart:typed_data';

import 'pet.dart';

abstract class PetRepository {
  Future<List<Pet>> fetchPets({int limit = 50});

  Future<Pet?> getPetById(String petId);

  Future<List<Pet>> getPetsByOwner(String ownerId);

  Future<Pet> createPet(CreatePetInput input);

  Future<Pet> uploadPetPhoto(UploadPetPhotoInput input);
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

class UploadPetPhotoInput {
  const UploadPetPhotoInput({
    required this.petId,
    required this.fileName,
    required this.bytes,
    required this.contentType,
  });

  final String petId;
  final String fileName;
  final Uint8List bytes;
  final String contentType;

  int get sizeBytes => bytes.lengthInBytes;
}
