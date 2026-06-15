import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../application/pets_provider.dart';

class PetProfileScreen extends ConsumerWidget {
  const PetProfileScreen({required this.petId, super.key});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(petByIdProvider(petId));

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль питомца')),
      body: SafeArea(
        child: pet == null
            ? const ErrorState(
                title: 'Питомец не найден',
                message: 'Проверьте ссылку или вернитесь к списку питомцев.',
              )
            : ResponsiveCenter(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              pet.photoEmoji,
                              style: const TextStyle(fontSize: 96),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              pet.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                                '${pet.animalType} • ${pet.breed} • ${pet.age} г.'),
                            const SizedBox(height: 16),
                            Text(
                              pet.description,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('Владелец'),
                        subtitle: Text(pet.ownerName),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.favorite_outline),
                        title: const Text('Интересы'),
                        subtitle: const Text(
                            'Прогулки, игры и общение с другими питомцами'),
                        trailing: FilledButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Заявка на знакомство отправлена')),
                            );
                          },
                          child: const Text('Познакомиться'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
