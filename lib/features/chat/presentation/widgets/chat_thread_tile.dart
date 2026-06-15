import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../domain/chat_thread.dart';

class ChatThreadTile extends StatelessWidget {
  const ChatThreadTile({required this.thread, super.key});

  final ChatThread thread;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: colorScheme.tertiaryContainer,
          child: Text(thread.petName.characters.first),
        ),
        title: Text(thread.companionName),
        subtitle: Text('${thread.petName}: ${thread.lastMessage}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatRelativeDate(thread.updatedAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (thread.unreadCount > 0) ...[
              const SizedBox(height: 6),
              Badge(label: Text('${thread.unreadCount}')),
            ],
          ],
        ),
      ),
    );
  }
}
