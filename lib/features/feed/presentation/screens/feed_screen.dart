import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/analytics/analytics_event.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/async_content_view.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../auth/domain/app_user.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../application/feed_controller.dart';
import '../../domain/pet_post.dart';
import '../widgets/pet_stories_strip.dart';
import '../widgets/post_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(analyticsServiceProvider).track(AnalyticsEvent.feedOpened),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsValue = ref.watch(feedControllerProvider);
    final controller = ref.read(feedControllerProvider.notifier);
    final isSearching = controller.query.hasText;

    return AsyncContentView(
      value: postsValue,
      onRetry: controller.refresh,
      emptyIcon: Icons.dynamic_feed_outlined,
      emptyTitle: isSearching ? 'Ничего не найдено' : 'В ленте пока пусто',
      emptyMessage: isSearching
          ? 'Попробуйте другой запрос по посту, автору или питомцу.'
          : 'Создайте первый пост через кнопку добавления или обновите ленту.',
      emptyActionLabel: isSearching ? 'Сбросить поиск' : 'Обновить ленту',
      onEmptyActionPressed: isSearching ? _clearSearch : controller.refresh,
      isEmpty: (posts) => posts.isEmpty,
      dataBuilder: (posts) => ResponsiveCenter(
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
            itemCount: posts.length + 3,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const _FeedHeader();
              }

              if (index == 1) {
                return _FeedSearchField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onClear: _clearSearch,
                );
              }

              if (index == 2) {
                return const PetStoriesStrip();
              }

              final post = posts[index - 3];
              final currentUser = ref.watch(authStateProvider).valueOrNull;
              final canDelete =
                  currentUser != null && post.authorId == currentUser.id;
              return PostCard(
                post: post,
                onLike: () => controller.toggleLike(post.id),
                onDelete: canDelete
                    ? () => _confirmDeletePost(post, currentUser)
                    : null,
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

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(feedControllerProvider.notifier).updateSearchQuery(value);
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    unawaited(ref.read(feedControllerProvider.notifier).clearSearch());
  }

  Future<void> _confirmDeletePost(PetPost post, AppUser currentUser) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пост?'),
        content:
            const Text('Пост исчезнет из ленты. Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            key: Key('confirm-delete-post-${post.id}'),
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
      await ref.read(feedControllerProvider.notifier).deletePost(
            post: post,
            author: currentUser,
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пост удален')),
      );
    } on Object {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось удалить пост.')),
      );
    }
  }
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Живая лента питомцев',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Делитесь моментами, находите друзей и следите за прогулками рядом.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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

class _FeedSearchField extends StatelessWidget {
  const _FeedSearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: AppRadius.lg,
      padding: const EdgeInsets.all(12),
      child: TextField(
        key: const Key('feed-search-input'),
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                key: const Key('feed-search-clear'),
                onPressed: onClear,
                icon: const Icon(Icons.close),
                tooltip: 'Сбросить поиск',
              );
            },
          ),
          hintText: 'Поиск по постам, авторам и питомцам',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
