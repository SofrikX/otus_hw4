import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petconnect/core/data/mock_data.dart';
import 'package:petconnect/features/chat/application/chats_provider.dart';
import 'package:petconnect/features/chat/domain/chat_thread.dart';
import 'package:petconnect/features/chat/presentation/screens/chat_screen.dart';

void main() {
  testWidgets('ChatScreen shows mock chat threads and unread badge',
      (tester) async {
    await tester.pumpWidget(_buildChat());

    expect(find.text(mockChats.first.companionName), findsOneWidget);
    expect(
      find.text('${mockChats.first.petName}: ${mockChats.first.lastMessage}'),
      findsOneWidget,
    );
    expect(find.text('${mockChats.first.unreadCount}'), findsOneWidget);

    expect(find.text(mockChats.last.companionName), findsOneWidget);
    expect(
      find.text('${mockChats.last.petName}: ${mockChats.last.lastMessage}'),
      findsOneWidget,
    );
  });

  testWidgets('ChatScreen shows empty state when there are no chats',
      (tester) async {
    await tester.pumpWidget(
      _buildChat(
        chats: const [],
      ),
    );

    expect(find.text('Чатов пока нет'), findsOneWidget);
    expect(
      find.text(
          'Начните знакомство с владельцем питомца из ленты или прогулки.'),
      findsOneWidget,
    );
  });
}

Widget _buildChat({List<ChatThread>? chats}) {
  return ProviderScope(
    overrides: [
      if (chats != null)
        chatsProvider.overrideWith(
          (ref) => chats,
        ),
    ],
    child: const MaterialApp(
      home: Scaffold(body: ChatScreen()),
    ),
  );
}
