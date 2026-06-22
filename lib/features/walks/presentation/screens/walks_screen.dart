import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/async_content_view.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../auth/domain/app_user.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../application/walks_controller.dart';
import '../../domain/walk.dart';
import '../../domain/walks_repository.dart';
import '../widgets/walk_card.dart';

class WalksScreen extends ConsumerStatefulWidget {
  const WalksScreen({super.key});

  @override
  ConsumerState<WalksScreen> createState() => _WalksScreenState();
}

class _WalksScreenState extends ConsumerState<WalksScreen> {
  final TextEditingController _locationController = TextEditingController();
  Timer? _filterDebounce;

  @override
  void dispose() {
    _filterDebounce?.cancel();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walksValue = ref.watch(walksControllerProvider);
    final controller = ref.read(walksControllerProvider.notifier);
    final filters = controller.filters;
    final currentUser = ref.watch(authStateProvider).valueOrNull;
    final hasFilters = filters.hasActiveFilters;

    return Stack(
      children: [
        AsyncContentView(
          value: walksValue,
          onRetry: controller.refresh,
          emptyIcon: Icons.map_outlined,
          emptyTitle:
              hasFilters ? 'Подходящих прогулок нет' : 'Прогулок пока нет',
          emptyMessage: hasFilters
              ? 'Измените дату, место или статус прогулки.'
              : 'Активные встречи появятся здесь. Создайте первую прогулку.',
          emptyActionLabel:
              hasFilters ? 'Сбросить фильтры' : 'Создать прогулку',
          onEmptyActionPressed:
              hasFilters ? _clearFilters : () => _showCreateWalk(currentUser),
          isEmpty: (walks) => walks.isEmpty,
          dataBuilder: (walks) => ResponsiveCenter(
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 112),
                itemCount: walks.length + 2,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const _WalksHeader();
                  }

                  if (index == 1) {
                    return _WalkFiltersPanel(
                      filters: filters,
                      locationController: _locationController,
                      onLocationChanged: _onLocationChanged,
                      onStatusChanged: _onStatusChanged,
                      onPickDate: _pickDate,
                      onClearDate: _clearDate,
                      onClearFilters: _clearFilters,
                    );
                  }

                  final walk = walks[index - 2];
                  return WalkCard(
                    walk: walk,
                    onJoin: () => _joinWalk(walk),
                    onLeave: () => _leaveWalk(walk),
                  );
                },
              ),
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            key: const Key('add-walk-button'),
            onPressed: () => _showCreateWalk(currentUser),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Прогулка'),
          ),
        ),
      ],
    );
  }

  void _onLocationChanged(String value) {
    _filterDebounce?.cancel();
    _filterDebounce = Timer(const Duration(milliseconds: 350), () {
      final controller = ref.read(walksControllerProvider.notifier);
      unawaited(
        controller.updateFilters(
          controller.filters.copyWith(locationQuery: value),
        ),
      );
    });
  }

  void _onStatusChanged(WalkStatusFilter status) {
    final controller = ref.read(walksControllerProvider.notifier);
    unawaited(controller.updateFilters(controller.filters.copyWith(
      status: status,
    )));
  }

  Future<void> _pickDate() async {
    final controller = ref.read(walksControllerProvider.notifier);
    final now = DateTime.now();
    final currentDate = controller.filters.date ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) {
      return;
    }

    await controller.updateFilters(controller.filters.copyWith(date: picked));
  }

  void _clearDate() {
    final controller = ref.read(walksControllerProvider.notifier);
    unawaited(controller.updateFilters(controller.filters.copyWith(
      clearDate: true,
    )));
  }

  void _clearFilters() {
    _filterDebounce?.cancel();
    _locationController.clear();
    unawaited(ref.read(walksControllerProvider.notifier).clearFilters());
  }

  Future<void> _joinWalk(Walk walk) async {
    final status =
        await ref.read(walksControllerProvider.notifier).joinWalk(walk.id);
    if (!mounted) {
      return;
    }

    final message = switch (status) {
      WalkJoinStatus.joined => 'Вы присоединились: ${walk.title}',
      WalkJoinStatus.alreadyJoined => 'Вы уже участвуете: ${walk.title}',
      WalkJoinStatus.left => null,
      WalkJoinStatus.unavailable => null,
      WalkJoinStatus.failed => null,
    };
    if (message == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _leaveWalk(Walk walk) async {
    final status =
        await ref.read(walksControllerProvider.notifier).leaveWalk(walk.id);
    if (!mounted) {
      return;
    }

    final message = switch (status) {
      WalkJoinStatus.left => 'Вы вышли из прогулки: ${walk.title}',
      WalkJoinStatus.joined ||
      WalkJoinStatus.alreadyJoined ||
      WalkJoinStatus.unavailable ||
      WalkJoinStatus.failed =>
        null,
    };
    if (message == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showCreateWalk(AppUser? currentUser) async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Войдите, чтобы создать прогулку.')),
      );
      return;
    }

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _WalkFormSheet(
        onSubmit: ({
          required String title,
          required String place,
          required DateTime startsAt,
          required String description,
        }) {
          return ref.read(walksControllerProvider.notifier).createWalk(
                organizer: currentUser,
                title: title,
                place: place,
                startsAt: startsAt,
                description: description,
              );
        },
      ),
    );

    if (!mounted || created != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Прогулка создана')),
    );
  }
}

class _WalksHeader extends StatelessWidget {
  const _WalksHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Найдите прогулку рядом',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Выбирайте встречу поблизости, присоединяйтесь к участникам и следите за обновлениями.',
            ),
          ],
        ),
      ),
    );
  }
}

class _WalkFiltersPanel extends StatelessWidget {
  const _WalkFiltersPanel({
    required this.filters,
    required this.locationController,
    required this.onLocationChanged,
    required this.onStatusChanged,
    required this.onPickDate,
    required this.onClearDate,
    required this.onClearFilters,
  });

  final WalkFilters filters;
  final TextEditingController locationController;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<WalkStatusFilter> onStatusChanged;
  final VoidCallback onPickDate;
  final VoidCallback onClearDate;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final date = filters.date;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: const Key('walk-location-filter'),
          controller: locationController,
          onChanged: onLocationChanged,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.place_outlined),
            hintText: 'Город, парк или место',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ChoiceChip(
              key: const Key('walk-status-upcoming'),
              label: const Text('Предстоящие'),
              selected: filters.status == WalkStatusFilter.upcoming,
              onSelected: (_) => onStatusChanged(WalkStatusFilter.upcoming),
            ),
            ChoiceChip(
              key: const Key('walk-status-completed'),
              label: const Text('Завершенные'),
              selected: filters.status == WalkStatusFilter.completed,
              onSelected: (_) => onStatusChanged(WalkStatusFilter.completed),
            ),
            ChoiceChip(
              key: const Key('walk-status-all'),
              label: const Text('Все'),
              selected: filters.status == WalkStatusFilter.all,
              onSelected: (_) => onStatusChanged(WalkStatusFilter.all),
            ),
            ActionChip(
              key: const Key('walk-date-filter'),
              avatar: const Icon(Icons.event_outlined, size: 18),
              label: Text(date == null ? 'Дата' : _formatDate(date)),
              onPressed: onPickDate,
            ),
            if (date != null)
              IconButton(
                key: const Key('walk-date-clear'),
                onPressed: onClearDate,
                icon: const Icon(Icons.event_busy_outlined),
                tooltip: 'Сбросить дату',
              ),
            if (filters.hasActiveFilters)
              TextButton.icon(
                key: const Key('walk-clear-filters'),
                onPressed: onClearFilters,
                icon: const Icon(Icons.close),
                label: const Text('Сбросить'),
              ),
          ],
        ),
      ],
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}

typedef _WalkFormSubmit = Future<void> Function({
  required String title,
  required String place,
  required DateTime startsAt,
  required String description,
});

class _WalkFormSheet extends StatefulWidget {
  const _WalkFormSheet({required this.onSubmit});

  final _WalkFormSubmit onSubmit;

  @override
  State<_WalkFormSheet> createState() => _WalkFormSheetState();
}

class _WalkFormSheetState extends State<_WalkFormSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _startsAt = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 0);
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = _combinedDateTime();

    return SingleChildScrollView(
      child: Center(
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
                Text(
                  'Создать прогулку',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('walk-title-input'),
                  controller: _titleController,
                  enabled: !_isSaving,
                  maxLength: 120,
                  decoration: const InputDecoration(
                    labelText: 'Название',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  key: const Key('walk-place-input'),
                  controller: _placeController,
                  enabled: !_isSaving,
                  maxLength: 160,
                  decoration: const InputDecoration(
                    labelText: 'Место',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      key: const Key('walk-start-date-input'),
                      avatar: const Icon(Icons.event_outlined, size: 18),
                      label: Text(_formatDate(_startsAt)),
                      onPressed: _isSaving ? null : _pickDate,
                    ),
                    ActionChip(
                      key: const Key('walk-start-time-input'),
                      avatar: const Icon(Icons.schedule_outlined, size: 18),
                      label: Text(_time.format(context)),
                      onPressed: _isSaving ? null : _pickTime,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Старт: ${_formatDate(dateTime)} ${_time.format(context)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('walk-description-input'),
                  controller: _descriptionController,
                  enabled: !_isSaving,
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
                    key: const Key('walk-form-error'),
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('save-walk-button'),
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
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startsAt,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked == null) {
      return;
    }

    setState(() => _startsAt = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked == null) {
      return;
    }

    setState(() => _time = picked);
  }

  Future<void> _submit() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await widget.onSubmit(
        title: _titleController.text,
        place: _placeController.text,
        startsAt: _combinedDateTime(),
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

  DateTime _combinedDateTime() {
    return DateTime(
      _startsAt.year,
      _startsAt.month,
      _startsAt.day,
      _time.hour,
      _time.minute,
    );
  }
}

String _messageForError(Object error) {
  if (error is ArgumentError) {
    return error.message.toString();
  }

  return 'Не удалось сохранить прогулку. Попробуйте еще раз.';
}
