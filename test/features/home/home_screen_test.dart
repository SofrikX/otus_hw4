import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petconnect/core/data/mock_data.dart';
import 'package:petconnect/features/auth/domain/app_user.dart';
import 'package:petconnect/features/auth/presentation/auth_controller.dart';
import 'package:petconnect/features/feed/application/feed_controller.dart';
import 'package:petconnect/features/feed/domain/pet_post.dart';
import 'package:petconnect/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('HomeScreen validates empty post form without mutating feed',
      (tester) async {
    final controller = FeedController(initialPosts: [mockPosts.first]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream<AppUser?>.value(
              const AppUser(
                id: 'mock-user',
                email: 'owner@example.test',
                displayName: 'Owner',
              ),
            ),
          ),
          feedControllerProvider.overrideWith((ref) => controller),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('submit-create-post')));
    await tester.pumpAndSettle();

    expect(find.text('Напишите текст поста.'), findsOneWidget);
    expect(controller.state.value, <PetPost>[mockPosts.first]);
  });

  testWidgets('HomeScreen creates post with current user pet, not feed pet',
      (tester) async {
    final controller = FeedController(initialPosts: [mockPosts.first]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream<AppUser?>.value(
              const AppUser(
                id: 'user-2',
                email: 'max@example.test',
                displayName: 'Максим',
              ),
            ),
          ),
          feedControllerProvider.overrideWith((ref) => controller),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('create-post-input')),
      'Пост от владельца Мии',
    );
    await tester.tap(find.byKey(const Key('submit-create-post')));
    await tester.pumpAndSettle();

    final posts = controller.state.value;
    expect(posts, isNotNull);
    expect(posts!.first.petId, 'pet-2');
    expect(posts.first.petName, 'Мия');
  });
}
