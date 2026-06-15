import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/async_content_view.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../application/feed_controller.dart';
import '../widgets/pet_stories_strip.dart';
import '../widgets/post_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsValue = ref.watch(feedControllerProvider);
    final controller = ref.read(feedControllerProvider.notifier);

    return AsyncContentView(
      value: postsValue,
      onRetry: controller.refresh,
      emptyTitle: 'В ленте пока пусто',
      emptyMessage:
          'Подпишитесь на владельцев питомцев или создайте первый пост.',
      isEmpty: (posts) => posts.isEmpty,
      dataBuilder: (posts) => ResponsiveCenter(
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: posts.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const PetStoriesStrip();
              }

              final post = posts[index - 1];
              return PostCard(
                post: post,
                onLike: () => controller.toggleLike(post.id),
                onComment: (text) {
                  try {
                    controller.addComment(post.id, text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Комментарий добавлен')),
                    );
                  } on ArgumentError catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error.message.toString())),
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
