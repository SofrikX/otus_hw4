import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/backend_config.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/network/api_client.dart';
import '../data/api_pet_repository.dart';
import '../data/mock_pet_repository.dart';
import '../domain/pet.dart';
import '../domain/pet_repository.dart';

final petRepositoryProvider = Provider<PetRepository>((ref) {
  final config = ref.watch(backendConfigProvider);
  if (config.useFirebaseBackend) {
    return ApiPetRepository(ref.watch(apiClientProvider));
  }

  return MockPetRepository();
});

final petsProvider = FutureProvider<List<Pet>>((ref) async {
  final repository = ref.watch(petRepositoryProvider);
  if (repository is MockPetRepository) {
    return repository.getAllPets();
  }

  return List<Pet>.unmodifiable(mockPets);
});

final petsByOwnerProvider =
    FutureProvider.family<List<Pet>, String>((ref, ownerId) {
  return ref.watch(petRepositoryProvider).getPetsByOwner(ownerId);
});

final petByIdProvider = FutureProvider.family<Pet?, String>((ref, petId) {
  return ref.watch(petRepositoryProvider).getPetById(petId);
});
