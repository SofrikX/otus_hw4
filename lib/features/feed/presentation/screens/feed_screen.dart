import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/analytics/analytics_event.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/widgets/async_content_view.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../application/feed_controller.dart';
import '../widgets/pet_stories_strip.dart';
import '../widgets/post_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(analyticsServiceProvider).track(AnalyticsEvent.feedOpened),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postsValue = ref.watch(feedControllerProvider);
    final controller = ref.read(feedControllerProvider.notifier);

    return AsyncContentView(
      value: postsValue,
      onRetry: controller.refresh,
      emptyIcon: Icons.dynamic_feed_outlined,
      emptyTitle: 'В ленте пока пусто',
      emptyMessage:
          'Создайте первый пост через кнопку добавления или обновите ленту.',
      emptyActionLabel: 'Обновить ленту',
      onEmptyActionPressed: controller.refresh,
      isEmpty: (posts) => posts.isEmpty,
      dataBuilder: (posts) => ResponsiveCenter(
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: posts.length + 2,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const _FeedHeader();
              }

              if (index == 1) {
                return const PetStoriesStrip();
              }

              final post = posts[index - 2];
              return PostCard(
                post: post,
                onLike: () => controller.toggleLike(post.id),
                onComment: (text) async {
                  try {
                    await controller.addComment(
                      post.id,
                      text,
                      author: ref.read(authStateProvider).valueOrNull,
                    );
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Комментарий добавлен')),
                    );
                  } on ArgumentError catch (error) {
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error.message.toString())),
                    );
                  } on Object {
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Не удалось добавить комментарий.'),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Привет!\nЧто нового у питомца?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
            ),
          ),
          IconButton.filledTonal(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Новых уведомлений пока нет.')),
              );
            },
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Уведомления',
          ),
        ],
      ),
    );
  }
}
