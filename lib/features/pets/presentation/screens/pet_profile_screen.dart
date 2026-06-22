import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/async_content_view.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../application/pet_photo_controller.dart';
import '../../application/pet_photo_picker.dart';
import '../../application/pets_provider.dart';
import '../../domain/pet.dart';
import '../widgets/pet_photo_view.dart';

class PetProfileScreen extends ConsumerWidget {
  const PetProfileScreen({required this.petId, super.key});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(petByIdProvider(petId));

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль питомца')),
      body: SafeArea(
        child: AsyncContentView<Pet?>(
          value: pet,
          onRetry: () => ref.invalidate(petByIdProvider(petId)),
          dataBuilder: (pet) {
            if (pet == null) {
              return const ErrorState(
                title: 'Питомец не найден',
                message: 'Проверьте ссылку или вернитесь к списку питомцев.',
              );
            }

            return _PetProfileContent(pet: pet);
          },
        ),
      ),
    );
  }
}

class _PetProfileContent extends ConsumerWidget {
  const _PetProfileContent({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).valueOrNull;
    final canUploadPhoto = currentUser?.id == pet.ownerId;

    return ResponsiveCenter(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PetSummaryCard(
            pet: pet,
            canUploadPhoto: canUploadPhoto,
          ),
          const SizedBox(height: 16),
          _OwnerCard(ownerName: pet.ownerName),
          const SizedBox(height: 12),
          const _PetInterestsCard(),
        ],
      ),
    );
  }
}

class _PetSummaryCard extends StatelessWidget {
  const _PetSummaryCard({
    required this.pet,
    required this.canUploadPhoto,
  });

  final Pet pet;
  final bool canUploadPhoto;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            PetPhotoView(
              pet: pet,
              size: 160,
              borderRadius: 32,
            ),
            if (canUploadPhoto) ...[
              const SizedBox(height: 12),
              _PetPhotoUploadButton(petId: pet.id),
            ],
            const SizedBox(height: 16),
            Text(
              pet.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text('${pet.animalType} • ${pet.breed} • ${pet.age} г.'),
            const SizedBox(height: 16),
            Text(
              pet.description,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PetPhotoUploadButton extends ConsumerWidget {
  const _PetPhotoUploadButton({required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(petPhotoControllerProvider(petId));
    final isLoading = uploadState.isLoading;

    return Column(
      children: [
        FilledButton.icon(
          onPressed: isLoading
              ? null
              : () async {
                  final updatedPet = await ref
                      .read(petPhotoControllerProvider(petId).notifier)
                      .pickAndUpload();
                  if (updatedPet != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Фото питомца обновлено')),
                    );
                  }
                },
          icon: isLoading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add_photo_alternate_outlined),
          label: Text(isLoading ? 'Загрузка...' : 'Загрузить фото'),
        ),
        if (uploadState.hasError) ...[
          const SizedBox(height: 8),
          Text(
            _petPhotoErrorMessage(uploadState.error),
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }

  String _petPhotoErrorMessage(Object? error) {
    if (error is PetPhotoValidationException) {
      return error.message;
    }

    return 'Не удалось загрузить фото. Попробуйте ещё раз.';
  }
}

class _OwnerCard extends StatelessWidget {
  const _OwnerCard({required this.ownerName});

  final String ownerName;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person_outline),
        title: const Text('Владелец'),
        subtitle: Text(ownerName),
      ),
    );
  }
}

class _PetInterestsCard extends StatelessWidget {
  const _PetInterestsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.favorite_outline),
        title: const Text('Интересы'),
        subtitle: const Text('Прогулки, игры и общение с другими питомцами'),
        trailing: FilledButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Заявка на знакомство отправлена')),
            );
          },
          child: const Text('Познакомиться'),
        ),
      ),
    );
  }
}
