import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petconnect/core/data/mock_data.dart';
import 'package:petconnect/features/feed/presentation/widgets/post_card.dart';

void main() {
  testWidgets('PostCard displays post data and handles like tap',
      (tester) async {
    final post = mockPosts.first;
    var likeTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PostCard(
            post: post,
            onLike: () => likeTapped = true,
            onComment: (_) {},
          ),
        ),
      ),
    );

    expect(find.text(post.petName), findsOneWidget);
    expect(find.text(post.text), findsOneWidget);

    await tester.tap(find.byKey(Key('like-${post.id}')));
    await tester.pump();

    expect(likeTapped, isTrue);
  });
}
