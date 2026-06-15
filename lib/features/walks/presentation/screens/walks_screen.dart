import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/async_content_view.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../application/walks_controller.dart';
import '../widgets/walk_card.dart';

class WalksScreen extends ConsumerWidget {
  const WalksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walksValue = ref.watch(walksControllerProvider);
    final controller = ref.read(walksControllerProvider.notifier);

    return AsyncContentView(
      value: walksValue,
      onRetry: controller.refresh,
      emptyTitle: 'Прогулок пока нет',
      emptyMessage: 'Создайте первую прогулку и пригласите владельцев рядом.',
      isEmpty: (walks) => walks.isEmpty,
      dataBuilder: (walks) => ResponsiveCenter(
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: walks.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const _WalksHeader();
              }

              final walk = walks[index - 1];
              return WalkCard(
                walk: walk,
                onJoin: () {
                  controller.joinWalk(walk.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Вы присоединились: ${walk.title}')),
                  );
                },
              );
            },
          ),
        ),
      ),
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
              'MVP использует mock-данные. Геолокация и карта будут подключены после Firebase-интеграции.',
            ),
          ],
        ),
      ),
    );
  }
}
