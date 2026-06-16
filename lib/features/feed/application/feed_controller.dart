import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/mock_data.dart';
import '../../../core/network/api_client.dart';
import '../data/api_feed_repository.dart';
import '../data/mock_feed_repository.dart';
import '../domain/feed_repository.dart';
import '../domain/pet_post.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final config = ref.watch(backendConfigProvider);
  if (config.useFirebaseBackend) {
    return ApiFeedRepository(ref.watch(apiClientProvider));
  }

  return MockFeedRepository();
});

final feedControllerProvider =
    StateNotifierProvider<FeedController, AsyncValue<List<PetPost>>>((ref) {
  final controller = FeedController(
    repository: ref.watch(feedRepositoryProvider),
    loadOnStart: ref.watch(backendConfigProvider).useFirebaseBackend,
  );

  return controller;
});

class FeedController extends StateNotifier<AsyncValue<List<PetPost>>> {
  FeedController({
    FeedRepository? repository,
    AsyncValue<List<PetPost>>? initialState,
    List<PetPost>? initialPosts,
    bool loadOnStart = false,
  })  : _posts = _resolveInitialPosts(initialState, initialPosts),
        _repository = repository ??
            MockFeedRepository(
              initialPosts: _resolveInitialPosts(initialState, initialPosts),
            ),
        super(
          initialState ??
              AsyncValue.data(_resolveInitialPosts(initialState, initialPosts)),
        ) {
    if (loadOnStart) {
      unawaited(refresh());
    }
  }

  List<PetPost> _posts;
  final FeedRepository _repository;

  Future<void> refresh() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final posts = await _repository.fetchPosts();
      _posts = List<PetPost>.unmodifiable(posts);
      return _posts;
    });
  }

  void toggleLike(String postId) {
    final posts = state.asData?.value;
    if (posts == null) {
      return;
    }

    final optimisticPosts = posts.map((post) {
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

    _setPosts(optimisticPosts);
    unawaited(_syncLike(postId));
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

  Future<void> _syncLike(String postId) async {
    try {
      final result = await _repository.toggleLike(postId);
      final posts = state.asData?.value;
      if (posts == null) {
        return;
      }

      _setPosts(
        posts.map((post) {
          if (post.id != result.postId) {
            return post;
          }

          return post.copyWith(
            isLiked: result.isLiked,
            likesCount: result.likesCount,
          );
        }).toList(growable: false),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
