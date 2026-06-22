import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/pet.dart';
import 'pet_photo_view.dart';

class PetCard extends StatelessWidget {
  const PetCard({
    required this.pet,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final Pet pet;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      onTap: onTap,
      borderRadius: AppRadius.xl,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          PetPhotoView(pet: pet, size: 72),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _PetMetaChip(label: pet.animalType),
                    _PetMetaChip(label: pet.breed),
                    _PetMetaChip(label: '${pet.age} г.'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  pet.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          if (onEdit != null || onDelete != null)
            PopupMenuButton<_PetCardAction>(
              key: Key('pet-actions-${pet.id}'),
              tooltip: 'Действия с питомцем',
              onSelected: (action) {
                switch (action) {
                  case _PetCardAction.edit:
                    onEdit?.call();
                  case _PetCardAction.delete:
                    onDelete?.call();
                }
              },
              itemBuilder: (context) => [
                if (onEdit != null)
                  const PopupMenuItem(
                    value: _PetCardAction.edit,
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Редактировать'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                if (onDelete != null)
                  const PopupMenuItem(
                    value: _PetCardAction.delete,
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Удалить'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
              ],
            )
          else
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _PetMetaChip extends StatelessWidget {
  const _PetMetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.glassLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

enum _PetCardAction {
  edit,
  delete,
}
