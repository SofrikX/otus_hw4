import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/mock_data.dart';
import '../domain/pet_post.dart';

final feedControllerProvider =
    StateNotifierProvider<FeedController, AsyncValue<List<PetPost>>>((ref) {
  return FeedController();
});

class FeedController extends StateNotifier<AsyncValue<List<PetPost>>> {
  FeedController({
    AsyncValue<List<PetPost>>? initialState,
    List<PetPost>? initialPosts,
  })  : _posts = _resolveInitialPosts(initialState, initialPosts),
        super(
          initialState ??
              AsyncValue.data(_resolveInitialPosts(initialState, initialPosts)),
        );

  List<PetPost> _posts;

  Future<void> refresh({bool shouldFail = false}) async {
    state = const AsyncValue.loading();
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (shouldFail) {
      state = AsyncValue.error(
        Exception('Не удалось обновить ленту. Попробуйте позже.'),
        StackTrace.current,
      );
      return;
    }

    state = AsyncValue.data(_posts);
  }

  void toggleLike(String postId) {
    final posts = state.asData?.value;
    if (posts == null) {
      return;
    }

    final updated = posts.map((post) {
      if (post.id != postId) {
        return post;
      }

      final nextIsLiked = !post.isLiked;
      final nextLikesCount = post.likesCount + (nextIsLiked ? 1 : -1);

      return post.copyWith(
        isLiked: nextIsLiked,
        likesCount: nextLikesCount < 0 ? 0 : nextLikesCount,
      );
    }).toList(growable: false);

    _setPosts(updated);
  }

  void addComment(String postId, String text) {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      throw ArgumentError('Комментарий не может быть пустым');
    }

    final posts = state.asData?.value;
    if (posts == null) {
      return;
    }

    final updated = posts.map((post) {
      if (post.id != postId) {
        return post;
      }

      return post.copyWith(
        commentsCount: post.commentsCount + 1,
        comments: List<String>.unmodifiable([
          ...post.comments,
          trimmedText,
        ]),
      );
    }).toList(growable: false);

    _setPosts(updated);
  }

  static List<PetPost> _resolveInitialPosts(
    AsyncValue<List<PetPost>>? initialState,
    List<PetPost>? initialPosts,
  ) {
    return List<PetPost>.unmodifiable(
      initialPosts ?? initialState?.asData?.value ?? mockPosts,
    );
  }

  void _setPosts(List<PetPost> posts) {
    _posts = List<PetPost>.unmodifiable(posts);
    state = AsyncValue.data(_posts);
  }
}
