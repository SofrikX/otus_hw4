import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petconnect/core/data/mock_data.dart';
import 'package:petconnect/features/feed/application/feed_controller.dart';
import 'package:petconnect/features/feed/domain/pet_post.dart';
import 'package:petconnect/features/feed/presentation/screens/feed_screen.dart';

void main() {
  testWidgets('FeedScreen shows mock posts in success state', (tester) async {
    await tester.pumpWidget(_buildFeed());

    expect(find.text('Истории питомцев'), findsOneWidget);
    expect(find.text(mockPosts.first.petName), findsWidgets);
    expect(find.text(mockPosts.first.text), findsOneWidget);
  });

  testWidgets('FeedScreen shows loading state', (tester) async {
    await tester.pumpWidget(
      _buildFeed(
        controller: FeedController(
          initialState: const AsyncValue<List<PetPost>>.loading(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('FeedScreen shows empty state', (tester) async {
    await tester.pumpWidget(
      _buildFeed(
        controller: FeedController(
          initialState: const AsyncValue<List<PetPost>>.data([]),
          initialPosts: const [],
        ),
      ),
    );

    expect(find.text('В ленте пока пусто'), findsOneWidget);
    expect(
      find.text('Подпишитесь на владельцев питомцев или создайте первый пост.'),
      findsOneWidget,
    );
  });

  testWidgets('FeedScreen shows friendly error state', (tester) async {
    await tester.pumpWidget(
      _buildFeed(
        controller: FeedController(
          initialState: AsyncValue<List<PetPost>>.error(
            Exception('Тестовая ошибка загрузки'),
            StackTrace.current,
          ),
        ),
      ),
    );

    expect(find.text('Не удалось загрузить данные'), findsOneWidget);
    expect(find.text('Тестовая ошибка загрузки'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
  });

  testWidgets('FeedScreen updates like state', (tester) async {
    final post = mockPosts.first;

    await tester.pumpWidget(_buildFeed());

    expect(find.text('${post.likesCount}'), findsOneWidget);

    await tester.tap(find.byKey(Key('like-${post.id}')));
    await tester.pump();

    expect(find.text('${post.likesCount + 1}'), findsOneWidget);
  });

  testWidgets('FeedScreen adds comment to mock state', (tester) async {
    const comment = 'Потрясающая новость для Бруно!';
    final post = mockPosts.first;

    await tester.pumpWidget(_buildFeed());

    await tester.tap(find.byKey(Key('comment-${post.id}')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(Key('comment-input-${post.id}')), comment);
    await tester.tap(find.byKey(Key('send-comment-${post.id}')));
    await tester.pumpAndSettle();

    expect(find.text(comment), findsOneWidget);
    expect(find.text('${post.commentsCount + 1}'), findsOneWidget);
    expect(find.text('Комментарий добавлен'), findsOneWidget);
  });
}

Widget _buildFeed({FeedController? controller}) {
  return ProviderScope(
    overrides: [
      if (controller != null)
        feedControllerProvider.overrideWith(
          (ref) => controller,
        ),
    ],
    child: const MaterialApp(
      home: Scaffold(body: FeedScreen()),
    ),
  );
}
