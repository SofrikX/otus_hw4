import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petconnect/core/data/mock_data.dart';
import 'package:petconnect/features/feed/application/feed_controller.dart';
import 'package:petconnect/features/feed/domain/pet_post.dart';

void main() {
  test('toggleLike updates post like state in mock feed state', () {
    final controller = FeedController();
    final post = mockPosts.first;

    controller.toggleLike(post.id);

    final updatedPost = _firstPost(controller);
    expect(updatedPost?.isLiked, isTrue);
    expect(updatedPost?.likesCount, post.likesCount + 1);
  });

  test('addComment stores comment text in mock feed state', () {
    const comment = 'Бруно отлично справился!';
    final controller = FeedController();
    final post = mockPosts.first;

    controller.addComment(post.id, comment);

    final updatedPost = _firstPost(controller);
    expect(updatedPost?.commentsCount, post.commentsCount + 1);
    expect(updatedPost?.comments.last, comment);
  });
}

PetPost? _firstPost(FeedController controller) {
  return controller.state.when(
    data: (posts) => posts.first,
    error: (_, __) => null,
    loading: () => null,
  );
}
