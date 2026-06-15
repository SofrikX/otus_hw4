import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../domain/pet_post.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    required this.post,
    required this.onLike,
    required this.onComment,
    super.key,
  });

  final PetPost post;
  final VoidCallback onLike;
  final ValueChanged<String> onComment;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(post.petEmoji),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.petName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${post.authorName} • ${formatRelativeDate(post.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz),
                  tooltip: 'Дополнительно',
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 220,
            color: colorScheme.surfaceContainerHighest,
            child: Center(
              child: Text(
                post.imageEmoji,
                style: const TextStyle(fontSize: 88),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.text),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      key: Key('like-${post.id}'),
                      onPressed: onLike,
                      icon: Icon(
                        post.isLiked ? Icons.favorite : Icons.favorite_border,
                      ),
                      color: post.isLiked ? colorScheme.error : null,
                      tooltip: 'Лайк',
                    ),
                    Text('${post.likesCount}'),
                    const SizedBox(width: 16),
                    IconButton(
                      key: Key('comment-${post.id}'),
                      onPressed: () => _showCommentSheet(context),
                      icon: const Icon(Icons.mode_comment_outlined),
                      tooltip: 'Комментарий',
                    ),
                    Text('${post.commentsCount}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentSheet(BuildContext context) {
    final controller = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Комментарий к посту ${post.petName}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Напишите добрый комментарий',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  onComment(controller.text);
                  Navigator.of(context).pop();
                },
                child: const Text('Отправить'),
              ),
            ],
          ),
        );
      },
    ).whenComplete(controller.dispose);
  }
}
