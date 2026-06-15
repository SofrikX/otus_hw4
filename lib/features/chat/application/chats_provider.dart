import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/mock_data.dart';
import '../domain/chat_thread.dart';

final chatsProvider = Provider<List<ChatThread>>((ref) {
  final chats = List<ChatThread>.of(mockChats)
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return List<ChatThread>.unmodifiable(chats);
});
