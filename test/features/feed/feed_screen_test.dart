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
      find.text(
          'Создайте первый пост через кнопку добавления или обновите ленту.'),
      findsOneWidget,
    );
    expect(find.text('Обновить ленту'), findsOneWidget);
  });

  testWidgets('FeedScreen shows empty search state', (tester) async {
    await tester.pumpWidget(_buildFeed());

    await tester.enterText(
      find.byKey(const Key('feed-search-input')),
      'нет такого поста',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Ничего не найдено'), findsOneWidget);
    expect(
      find.text('Попробуйте другой запрос по посту, автору или питомцу.'),
      findsOneWidget,
    );
    expect(find.text('Сбросить поиск'), findsOneWidget);
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

    await tester.ensureVisible(find.byKey(Key('like-${post.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('like-${post.id}')));
    await tester.pump();

    expect(find.text('${post.likesCount + 1}'), findsOneWidget);
  });

  testWidgets('FeedScreen adds comment to mock state', (tester) async {
    const comment = 'Потрясающая новость для Бруно!';
    final post = mockPosts.first;

    await tester.pumpWidget(_buildFeed());

    await tester.ensureVisible(find.byKey(Key('comment-${post.id}')));
    await tester.pumpAndSettle();
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

  testWidgets('FeedScreen confirms and deletes own post', (tester) async {
    final post = mockPosts.first.copyWith(authorId: 'mock-user');

    await tester.pumpWidget(
      _buildFeed(
        controller: FeedController(initialPosts: [post]),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('post-actions-${post.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Удалить'));
    await tester.pumpAndSettle();

    expect(find.text('Удалить пост?'), findsOneWidget);

    await tester.tap(find.byKey(Key('confirm-delete-post-${post.id}')));
    await tester.pumpAndSettle();

    expect(find.text(post.text), findsNothing);
    expect(find.text('Пост удален'), findsOneWidget);
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
