import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/mock_data.dart';
import '../domain/pet_post.dart';

final feedControllerProvider =
    StateNotifierProvider<FeedController, AsyncValue<List<PetPost>>>((ref) {
  return FeedController();
});

class FeedController extends StateNotifier<AsyncValue<List<PetPost>>> {
  FeedController({AsyncValue<List<PetPost>>? initialState})
      : super(
          initialState ?? AsyncValue.data(List<PetPost>.unmodifiable(mockPosts)),
        );

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

    state = AsyncValue.data(List<PetPost>.unmodifiable(mockPosts));
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

    state = AsyncValue.data(updated);
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

      return post.copyWith(commentsCount: post.commentsCount + 1);
    }).toList(growable: false);

    state = AsyncValue.data(updated);
  }
}
