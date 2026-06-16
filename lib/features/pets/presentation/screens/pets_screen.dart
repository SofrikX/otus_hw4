import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/async_content_view.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../application/pets_provider.dart';
import '../../domain/pet.dart';
import '../widgets/pet_card.dart';

class PetsScreen extends ConsumerWidget {
  const PetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pets = ref.watch(petsProvider);

    return AsyncContentView<List<Pet>>(
      value: pets,
      isEmpty: (pets) => pets.isEmpty,
      emptyTitle: 'Питомцев пока нет',
      emptyMessage: 'Добавьте питомца, чтобы его профиль появился здесь.',
      onRetry: () => ref.invalidate(petsProvider),
      dataBuilder: (pets) => ResponsiveCenter(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          itemCount: pets.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final pet = pets[index];
            return PetCard(
              pet: pet,
              onTap: () => context.push('/pets/${pet.id}'),
            );
          },
        ),
      ),
    );
  }
}
