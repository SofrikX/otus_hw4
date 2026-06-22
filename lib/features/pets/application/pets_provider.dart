import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/backend_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/supabase/supabase_client_provider.dart';
import '../../auth/domain/app_user.dart';
import '../data/api_pet_repository.dart';
import '../data/mock_pet_repository.dart';
import '../data/supabase_pet_repository.dart';
import '../domain/pet.dart';
import '../domain/pet_repository.dart';

final petRepositoryProvider = Provider<PetRepository>((ref) {
  final config = ref.watch(backendConfigProvider);
  if (config.useSupabaseBackend) {
    return SupabasePetRepository(ref.watch(supabaseClientProvider));
  }

  if (config.useFirebaseBackend) {
    return ApiPetRepository(ref.watch(apiClientProvider));
  }

  return MockPetRepository();
});

final petsProvider = FutureProvider<List<Pet>>((ref) async {
  final repository = ref.watch(petRepositoryProvider);
  return repository.fetchPets();
});

final petFiltersProvider = StateProvider<PetFilters>((ref) {
  return const PetFilters();
});

final filteredPetsProvider = Provider<AsyncValue<List<Pet>>>((ref) {
  final filters = ref.watch(petFiltersProvider);
  return ref.watch(petsProvider).whenData(filters.apply);
});

final petsByOwnerProvider =
    FutureProvider.family<List<Pet>, String>((ref, ownerId) {
  return ref.watch(petRepositoryProvider).getPetsByOwner(ownerId);
});

final petByIdProvider = FutureProvider.family<Pet?, String>((ref, petId) {
  return ref.watch(petRepositoryProvider).getPetById(petId);
});

final petActionsProvider = Provider<PetActions>((ref) {
  return PetActions(ref);
});

class PetActions {
  const PetActions(this._ref);

  final Ref _ref;

  Future<Pet> createPet({
    required AppUser owner,
    required String name,
    required String animalType,
    required String breed,
    required String ageText,
    required String description,
  }) async {
    final input = _validatedCreateInput(
      owner: owner,
      name: name,
      animalType: animalType,
      breed: breed,
      ageText: ageText,
      description: description,
    );
    final pet = await _ref.read(petRepositoryProvider).createPet(input);
    _invalidatePetQueries(pet.id, owner.id);
    return pet;
  }

  Future<Pet> updatePet({
    required Pet pet,
    required AppUser owner,
    required String name,
    required String animalType,
    required String breed,
    required String ageText,
    required String description,
  }) async {
    if (pet.ownerId != owner.id) {
      throw ArgumentError('Можно редактировать только своего питомца.');
    }

    final input = _validatedUpdateInput(
      petId: pet.id,
      name: name,
      animalType: animalType,
      breed: breed,
      ageText: ageText,
      description: description,
      photoEmoji: pet.photoEmoji,
    );
    final updated = await _ref.read(petRepositoryProvider).updatePet(input);
    _invalidatePetQueries(updated.id, owner.id);
    return updated;
  }

  Future<void> deletePet({
    required Pet pet,
    required AppUser owner,
  }) async {
    if (pet.ownerId != owner.id) {
      throw ArgumentError('Можно удалить только своего питомца.');
    }

    await _ref.read(petRepositoryProvider).deletePet(pet.id);
    _invalidatePetQueries(pet.id, owner.id);
  }

  CreatePetInput _validatedCreateInput({
    required AppUser owner,
    required String name,
    required String animalType,
    required String breed,
    required String ageText,
    required String description,
  }) {
    final values = _validatePetFields(
      name: name,
      animalType: animalType,
      breed: breed,
      ageText: ageText,
      description: description,
    );

    return CreatePetInput(
      ownerId: owner.id,
      ownerName: owner.displayName ?? owner.email,
      name: values.name,
      animalType: values.animalType,
      breed: values.breed,
      age: values.age,
      description: values.description,
      photoEmoji: _emojiForAnimalType(values.animalType),
    );
  }

  UpdatePetInput _validatedUpdateInput({
    required String petId,
    required String name,
    required String animalType,
    required String breed,
    required String ageText,
    required String description,
    String? photoEmoji,
  }) {
    final values = _validatePetFields(
      name: name,
      animalType: animalType,
      breed: breed,
      ageText: ageText,
      description: description,
    );

    return UpdatePetInput(
      petId: petId,
      name: values.name,
      animalType: values.animalType,
      breed: values.breed,
      age: values.age,
      description: values.description,
      photoEmoji: photoEmoji ?? _emojiForAnimalType(values.animalType),
    );
  }

  _ValidatedPetFields _validatePetFields({
    required String name,
    required String animalType,
    required String breed,
    required String ageText,
    required String description,
  }) {
    final trimmedName = name.trim();
    final trimmedBreed = breed.trim();
    final trimmedDescription = description.trim();
    final normalizedAnimalType = animalType.trim().toLowerCase();
    final age = int.tryParse(ageText.trim());

    if (trimmedName.isEmpty) {
      throw ArgumentError('Укажите имя питомца.');
    }
    if (trimmedName.length > 50) {
      throw ArgumentError('Имя питомца должно быть до 50 символов.');
    }
    if (!{'dog', 'cat', 'other'}.contains(normalizedAnimalType)) {
      throw ArgumentError('Выберите тип питомца.');
    }
    if (trimmedBreed.length > 80) {
      throw ArgumentError('Порода должна быть до 80 символов.');
    }
    if (age == null || age < 0 || age > 30) {
      throw ArgumentError('Возраст должен быть числом от 0 до 30.');
    }
    if (trimmedDescription.isEmpty) {
      throw ArgumentError('Добавьте короткое описание питомца.');
    }
    if (trimmedDescription.length > 500) {
      throw ArgumentError('Описание должно быть до 500 символов.');
    }

    return _ValidatedPetFields(
      name: trimmedName,
      animalType: normalizedAnimalType,
      breed: trimmedBreed,
      age: age,
      description: trimmedDescription,
    );
  }

  String _emojiForAnimalType(String animalType) {
    return switch (animalType) {
      'dog' => '🐶',
      'cat' => '🐱',
      _ => '🐾',
    };
  }

  void _invalidatePetQueries(String petId, String ownerId) {
    _ref.invalidate(petsProvider);
    _ref.invalidate(petByIdProvider(petId));
    _ref.invalidate(petsByOwnerProvider(ownerId));
  }
}

class _ValidatedPetFields {
  const _ValidatedPetFields({
    required this.name,
    required this.animalType,
    required this.breed,
    required this.age,
    required this.description,
  });

  final String name;
  final String animalType;
  final String breed;
  final int age;
  final String description;
}

class PetFilters {
  const PetFilters({
    this.query = '',
    this.animalType,
  });

  final String query;
  final String? animalType;

  String get normalizedQuery => query.trim().toLowerCase();

  bool get hasActiveFilters {
    return normalizedQuery.isNotEmpty || animalType != null;
  }

  PetFilters copyWith({
    String? query,
    String? animalType,
    bool clearAnimalType = false,
  }) {
    return PetFilters(
      query: query ?? this.query,
      animalType: clearAnimalType ? null : animalType ?? this.animalType,
    );
  }

  List<Pet> apply(List<Pet> pets) {
    return pets.where(matches).toList(growable: false);
  }

  bool matches(Pet pet) {
    final type = animalType;
    if (type != null &&
        pet.animalType.trim().toLowerCase() != type.trim().toLowerCase()) {
      return false;
    }

    final text = normalizedQuery;
    if (text.isEmpty) {
      return true;
    }

    return pet.name.toLowerCase().contains(text);
  }
}
