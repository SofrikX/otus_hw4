import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petconnect/features/pets/application/pet_photo_controller.dart';
import 'package:petconnect/features/pets/application/pet_photo_picker.dart';
import 'package:petconnect/features/pets/application/pets_provider.dart';
import 'package:petconnect/features/pets/domain/pet.dart';
import 'package:petconnect/features/pets/domain/pet_repository.dart';

void main() {
  test('uploads a valid selected pet photo through repository', () async {
    final repository = _RecordingPetRepository();
    final container = ProviderContainer(
      overrides: [
        petRepositoryProvider.overrideWithValue(repository),
        petPhotoPickerProvider.overrideWithValue(
          _FakePetPhotoPicker(
            PickedPetPhoto(
              name: 'bruno.webp',
              bytes: _smallImageBytes,
              contentType: 'image/webp',
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final updatedPet = await container
        .read(petPhotoControllerProvider('pet-1').notifier)
        .pickAndUpload();

    expect(updatedPet?.photoUrl, 'https://example.test/bruno.webp');
    expect(repository.lastUpload?.petId, 'pet-1');
    expect(repository.lastUpload?.contentType, 'image/webp');
  });

  test('rejects unsupported image type before repository upload', () async {
    final repository = _RecordingPetRepository();
    final container = ProviderContainer(
      overrides: [
        petRepositoryProvider.overrideWithValue(repository),
        petPhotoPickerProvider.overrideWithValue(
          _FakePetPhotoPicker(
            PickedPetPhoto(
              name: 'bruno.gif',
              bytes: _smallImageBytes,
              contentType: 'image/gif',
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final updatedPet = await container
        .read(petPhotoControllerProvider('pet-1').notifier)
        .pickAndUpload();

    expect(updatedPet, isNull);
    expect(repository.lastUpload, isNull);
    expect(
      container.read(petPhotoControllerProvider('pet-1')).error,
      isA<PetPhotoValidationException>(),
    );
  });

  test('rejects too large image before repository upload', () async {
    final repository = _RecordingPetRepository();
    final container = ProviderContainer(
      overrides: [
        petRepositoryProvider.overrideWithValue(repository),
        petPhotoPickerProvider.overrideWithValue(
          _FakePetPhotoPicker(
            PickedPetPhoto(
              name: 'bruno.jpg',
              bytes: Uint8List(maxPetPhotoSizeBytes + 1),
              contentType: 'image/jpeg',
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(petPhotoControllerProvider('pet-1').notifier)
        .pickAndUpload();

    expect(repository.lastUpload, isNull);
    expect(
      container.read(petPhotoControllerProvider('pet-1')).error,
      isA<PetPhotoValidationException>(),
    );
  });
}

final _smallImageBytes = Uint8List.fromList([1, 2, 3, 4]);

class _FakePetPhotoPicker implements PetPhotoPicker {
  const _FakePetPhotoPicker(this.photo);

  final PickedPetPhoto? photo;

  @override
  Future<PickedPetPhoto?> pickPhoto() async => photo;
}

class _RecordingPetRepository implements PetRepository {
  UploadPetPhotoInput? lastUpload;

  @override
  Future<Pet> uploadPetPhoto(UploadPetPhotoInput input) async {
    lastUpload = input;
    return _pet.copyWith(photoUrl: 'https://example.test/${input.fileName}');
  }

  @override
  Future<Pet> createPet(CreatePetInput input) async => _pet;

  @override
  Future<Pet> updatePet(UpdatePetInput input) async => _pet;

  @override
  Future<void> deletePet(String petId) async {}

  @override
  Future<List<Pet>> fetchPets({int limit = 50}) async => [_pet];

  @override
  Future<Pet?> getPetById(String petId) async => _pet;

  @override
  Future<List<Pet>> getPetsByOwner(String ownerId) async => [_pet];
}

const _pet = Pet(
  id: 'pet-1',
  ownerId: 'user-1',
  name: 'Bruno',
  animalType: 'dog',
  breed: 'Corgi',
  age: 3,
  description: 'Loves parks',
  photoEmoji: 'dog',
  ownerName: 'Ava',
);
