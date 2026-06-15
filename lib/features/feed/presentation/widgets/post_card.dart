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
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(post: post),
          _PostMedia(post: post),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.text),
                const SizedBox(height: 12),
                _PostActions(
                  post: post,
                  onLike: onLike,
                  onCommentPressed: () => _showCommentSheet(context),
                ),
                _RecentComments(comments: post.comments),
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

class _PostHeader extends StatelessWidget {
  const _PostHeader({required this.post});

  final PetPost post;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
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
    );
  }
}

class _PostMedia extends StatelessWidget {
  const _PostMedia({required this.post});

  final PetPost post;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaHeight = (constraints.maxWidth * 0.58).clamp(220.0, 300.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: mediaHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  post.imageEmoji,
                  style: const TextStyle(fontSize: 88),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PostActions extends StatelessWidget {
  const _PostActions({
    required this.post,
    required this.onLike,
    required this.onCommentPressed,
  });

  final PetPost post;
  final VoidCallback onLike;
  final VoidCallback onCommentPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
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
          onPressed: onCommentPressed,
          icon: const Icon(Icons.mode_comment_outlined),
          tooltip: 'Комментарий',
        ),
        Text('${post.commentsCount}'),
      ],
    );
  }
}

class _RecentComments extends StatelessWidget {
  const _RecentComments({required this.comments});

  final List<String> comments;

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: comments.reversed.take(2).map((comment) {
          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              comment,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          );
        }).toList(growable: false),
      ),
    );
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
