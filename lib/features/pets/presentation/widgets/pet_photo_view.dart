import 'package:flutter/material.dart';

import '../../domain/pet.dart';

class PetPhotoView extends StatelessWidget {
  const PetPhotoView({
    required this.pet,
    required this.size,
    this.borderRadius = 24,
    super.key,
  });

  final Pet pet;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final photoUrl = pet.photoUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox.square(
        dimension: size,
        child: photoUrl == null || photoUrl.isEmpty
            ? _PetPhotoPlaceholder(pet: pet)
            : Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _PetPhotoPlaceholder(pet: pet),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return ColoredBox(
                    color: colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _PetPhotoPlaceholder extends StatelessWidget {
  const _PetPhotoPlaceholder({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.primaryContainer,
      child: Center(
        child: Text(
          pet.photoEmoji,
          style: TextStyle(fontSize: pet.photoEmoji.length > 2 ? 28 : 34),
        ),
      ),
    );
  }
}
