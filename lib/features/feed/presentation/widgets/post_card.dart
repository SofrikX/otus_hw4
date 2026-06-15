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
                if (post.comments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: post.comments.reversed.take(2).map((comment) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          comment,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      );
                    }).toList(growable: false),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentSheet(BuildContext context) {
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _CommentSheet(post: post),
    ).then((comment) {
      if (comment != null) {
        onComment(comment);
      }
    });
  }
}

class _CommentSheet extends StatefulWidget {
  const _CommentSheet({required this.post});

  final PetPost post;

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
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
              'Комментарий к посту ${widget.post.petName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              key: Key('comment-input-${widget.post.id}'),
              controller: _controller,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Напишите добрый комментарий',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: Key('send-comment-${widget.post.id}'),
              onPressed: () => Navigator.of(context).pop(_controller.text),
              child: const Text('Отправить'),
            ),
          ],
        ),
      ),
    );
  }
}
