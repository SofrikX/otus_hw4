import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/mock_data.dart';
import '../domain/pet.dart';

final petsProvider = Provider<List<Pet>>((ref) {
  return List<Pet>.unmodifiable(mockPets);
});

final petByIdProvider = Provider.family<Pet?, String>((ref, petId) {
  final pets = ref.watch(petsProvider);

  for (final pet in pets) {
    if (pet.id == petId) {
      return pet;
    }
  }

  return null;
});
