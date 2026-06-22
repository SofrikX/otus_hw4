import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/pet.dart';
import '../domain/pet_repository.dart';
import 'pet_photo_picker.dart';
import 'pets_provider.dart';

final petPhotoControllerProvider =
    StateNotifierProvider.family<PetPhotoController, AsyncValue<Pet?>, String>(
        (ref, petId) {
  return PetPhotoController(
    petId: petId,
    repository: ref.watch(petRepositoryProvider),
    picker: ref.watch(petPhotoPickerProvider),
    ref: ref,
  );
});

class PetPhotoController extends StateNotifier<AsyncValue<Pet?>> {
  PetPhotoController({
    required String petId,
    required PetRepository repository,
    required PetPhotoPicker picker,
    required Ref ref,
  })  : _petId = petId,
        _repository = repository,
        _picker = picker,
        _ref = ref,
        super(const AsyncValue.data(null));

  final String _petId;
  final PetRepository _repository;
  final PetPhotoPicker _picker;
  final Ref _ref;

  Future<Pet?> pickAndUpload() async {
    state = const AsyncValue.loading();
    try {
      final photo = await _picker.pickPhoto();
      if (photo == null) {
        state = const AsyncValue.data(null);
        return null;
      }

      validatePetPhoto(photo);

      final updatedPet = await _repository.uploadPetPhoto(
        UploadPetPhotoInput(
          petId: _petId,
          fileName: photo.name,
          bytes: photo.bytes,
          contentType: photo.contentType,
        ),
      );

      _ref.invalidate(petsProvider);
      _ref.invalidate(petByIdProvider(_petId));
      state = AsyncValue.data(updatedPet);
      return updatedPet;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }
}
