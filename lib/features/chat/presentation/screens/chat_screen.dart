import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../application/chats_provider.dart';
import '../widgets/chat_thread_tile.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatsProvider);

    if (chats.isEmpty) {
      return const EmptyState(
        title: 'Чатов пока нет',
        message:
            'Начните знакомство с владельцем питомца из ленты или прогулки.',
      );
    }

    return ResponsiveCenter(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: chats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return ChatThreadTile(thread: chats[index]);
        },
      ),
    );
  }
}
