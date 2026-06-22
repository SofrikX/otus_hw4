import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/async_content_view.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../auth/domain/app_user.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../application/pets_provider.dart';
import '../../domain/pet.dart';
import '../widgets/pet_card.dart';

class PetsScreen extends ConsumerStatefulWidget {
  const PetsScreen({super.key});

  @override
  ConsumerState<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends ConsumerState<PetsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pets = ref.watch(filteredPetsProvider);
    final allPets = ref.watch(petsProvider).valueOrNull ?? const <Pet>[];
    final filters = ref.watch(petFiltersProvider);
    final currentUser = ref.watch(authStateProvider).valueOrNull;
    final hasFilters = filters.hasActiveFilters;

    return Stack(
      children: [
        AsyncContentView<List<Pet>>(
          value: pets,
          isEmpty: (pets) => pets.isEmpty,
          emptyIcon: Icons.pets_outlined,
          emptyTitle: hasFilters ? 'Питомцы не найдены' : 'Питомцев пока нет',
          emptyMessage: hasFilters
              ? 'Измените имя питомца или тип животного.'
              : 'Когда вы добавите профиль питомца, он появится в этом списке.',
          emptyActionLabel:
              hasFilters ? 'Сбросить фильтры' : 'Добавить питомца',
          onEmptyActionPressed: hasFilters
              ? _clearFilters
              : () => _showPetForm(currentUser: currentUser),
          onRetry: () => ref.invalidate(petsProvider),
          dataBuilder: (pets) => ResponsiveCenter(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 112),
              itemCount: pets.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _PetFiltersPanel(
                    filters: filters,
                    availableTypes: _availableTypes(allPets),
                    searchController: _searchController,
                    onQueryChanged: _onQueryChanged,
                    onTypeChanged: _onTypeChanged,
                    onClearFilters: _clearFilters,
                  );
                }

                final pet = pets[index - 1];
                final isOwner = currentUser?.id == pet.ownerId;
                return PetCard(
                  pet: pet,
                  onTap: () => context.push('/pets/${pet.id}'),
                  onEdit: isOwner
                      ? () => _showPetForm(
                            currentUser: currentUser,
                            pet: pet,
                          )
                      : null,
                  onDelete: isOwner
                      ? () => _confirmDeletePet(pet, currentUser)
                      : null,
                );
              },
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            key: const Key('add-pet-button'),
            onPressed: () => _showPetForm(currentUser: currentUser),
            icon: const Icon(Icons.add),
            label: const Text('Питомец'),
          ),
        ),
      ],
    );
  }

  void _onQueryChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      final filters = ref.read(petFiltersProvider);
      ref.read(petFiltersProvider.notifier).state = filters.copyWith(
        query: value,
      );
    });
  }

  void _onTypeChanged(String? type) {
    final filters = ref.read(petFiltersProvider);
    ref.read(petFiltersProvider.notifier).state = type == null
        ? filters.copyWith(clearAnimalType: true)
        : filters.copyWith(animalType: type);
  }

  void _clearFilters() {
    _searchDebounce?.cancel();
    _searchController.clear();
    ref.read(petFiltersProvider.notifier).state = const PetFilters();
  }

  List<String> _availableTypes(List<Pet> pets) {
    final types = pets
        .map((pet) => pet.animalType.trim())
        .where((type) => type.isNotEmpty)
        .toSet()
        .toList();
    types.sort((left, right) => _animalTypeLabel(left).compareTo(
          _animalTypeLabel(right),
        ));
    return types;
  }

  Future<void> _showPetForm({
    required AppUser? currentUser,
    Pet? pet,
  }) async {
    if (currentUser == null) {
      _showMessage('Войдите, чтобы управлять питомцами.');
      return;
    }

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _PetFormSheet(
        pet: pet,
        onSubmit: ({
          required String name,
          required String animalType,
          required String breed,
          required String ageText,
          required String description,
        }) async {
          if (pet == null) {
            await ref.read(petActionsProvider).createPet(
                  owner: currentUser,
                  name: name,
                  animalType: animalType,
                  breed: breed,
                  ageText: ageText,
                  description: description,
                );
          } else {
            await ref.read(petActionsProvider).updatePet(
                  pet: pet,
                  owner: currentUser,
                  name: name,
                  animalType: animalType,
                  breed: breed,
                  ageText: ageText,
                  description: description,
                );
          }
        },
      ),
    );

    if (!mounted || saved != true) {
      return;
    }

    _showMessage(pet == null ? 'Питомец добавлен' : 'Профиль питомца обновлен');
  }

  Future<void> _confirmDeletePet(Pet pet, AppUser? currentUser) async {
    if (currentUser == null) {
      _showMessage('Войдите, чтобы управлять питомцами.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить питомца?'),
        content: Text(
          'Профиль ${pet.name} будет удален. Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            key: Key('confirm-delete-pet-${pet.id}'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref.read(petActionsProvider).deletePet(
            pet: pet,
            owner: currentUser,
          );
      if (!mounted) {
        return;
      }
      _showMessage('Питомец удален');
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(_messageForError(error));
    }
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _PetFiltersPanel extends StatelessWidget {
  const _PetFiltersPanel({
    required this.filters,
    required this.availableTypes,
    required this.searchController,
    required this.onQueryChanged,
    required this.onTypeChanged,
    required this.onClearFilters,
  });

  final PetFilters filters;
  final List<String> availableTypes;
  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String?> onTypeChanged;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: const Key('pet-search-input'),
          controller: searchController,
          onChanged: onQueryChanged,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Поиск питомца по имени',
            border: OutlineInputBorder(),
          ),
        ),
        if (availableTypes.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                key: const Key('pet-type-all'),
                label: const Text('Все'),
                selected: filters.animalType == null,
                onSelected: (_) => onTypeChanged(null),
              ),
              for (final type in availableTypes)
                ChoiceChip(
                  key: Key('pet-type-$type'),
                  label: Text(_animalTypeLabel(type)),
                  selected: filters.animalType == type,
                  onSelected: (_) => onTypeChanged(type),
                ),
              if (filters.hasActiveFilters)
                TextButton.icon(
                  key: const Key('pet-clear-filters'),
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.close),
                  label: const Text('Сбросить'),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

String _animalTypeLabel(String type) {
  return switch (type.trim().toLowerCase()) {
    'dog' => 'Собака',
    'cat' => 'Кошка',
    'other' => 'Другой',
    _ => type,
  };
}

typedef _PetFormSubmit = Future<void> Function({
  required String name,
  required String animalType,
  required String breed,
  required String ageText,
  required String description,
});

class _PetFormSheet extends StatefulWidget {
  const _PetFormSheet({
    required this.onSubmit,
    this.pet,
  });

  final Pet? pet;
  final _PetFormSubmit onSubmit;

  @override
  State<_PetFormSheet> createState() => _PetFormSheetState();
}

class _PetFormSheetState extends State<_PetFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _breedController;
  late final TextEditingController _ageController;
  late final TextEditingController _descriptionController;
  String _animalType = 'dog';
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final pet = widget.pet;
    _nameController = TextEditingController(text: pet?.name ?? '');
    _breedController = TextEditingController(text: pet?.breed ?? '');
    _ageController = TextEditingController(
      text: pet == null ? '' : pet.age.toString(),
    );
    _descriptionController = TextEditingController(
      text: pet?.description ?? '',
    );
    _animalType = _normalizeAnimalType(pet?.animalType ?? 'dog');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.pet == null ? 'Добавить питомца' : 'Редактировать';

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                key: const Key('pet-name-input'),
                controller: _nameController,
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: 'Имя',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                key: const Key('pet-type-input'),
                segments: const [
                  ButtonSegment(value: 'dog', label: Text('Собака')),
                  ButtonSegment(value: 'cat', label: Text('Кошка')),
                  ButtonSegment(value: 'other', label: Text('Другой')),
                ],
                selected: {_animalType},
                onSelectionChanged: _isSaving
                    ? null
                    : (value) => setState(() => _animalType = value.single),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('pet-breed-input'),
                controller: _breedController,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: 'Порода',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('pet-age-input'),
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Возраст',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('pet-description-input'),
                controller: _descriptionController,
                maxLength: 500,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  key: const Key('pet-form-error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('save-pet-button'),
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'Сохранение...' : 'Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await widget.onSubmit(
        name: _nameController.text,
        animalType: _animalType,
        breed: _breedController.text,
        ageText: _ageController.text,
        description: _descriptionController.text,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = _messageForError(error);
        _isSaving = false;
      });
    }
  }

  String _normalizeAnimalType(String animalType) {
    return switch (animalType.trim().toLowerCase()) {
      'dog' || 'собака' => 'dog',
      'cat' || 'кошка' => 'cat',
      _ => 'other',
    };
  }
}

String _messageForError(Object error) {
  if (error is ArgumentError) {
    return error.message.toString();
  }

  return 'Не удалось сохранить изменения. Попробуйте еще раз.';
}
