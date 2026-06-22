import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../../core/config/backend_config.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/supabase/supabase_client_provider.dart';
import '../../auth/domain/app_user.dart';
import '../data/mock_feed_repository.dart';
import '../data/supabase_feed_repository.dart';
import '../domain/feed_repository.dart';
import '../domain/pet_post.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final config = ref.watch(backendConfigProvider);
  if (config.useSupabaseBackend) {
    return SupabaseFeedRepository(ref.watch(supabaseClientProvider));
  }

  return MockFeedRepository();
});

final feedControllerProvider =
    StateNotifierProvider<FeedController, AsyncValue<List<PetPost>>>((ref) {
  final controller = FeedController(
    repository: ref.watch(feedRepositoryProvider),
    analytics: ref.watch(analyticsServiceProvider),
    loadOnStart: ref.watch(backendConfigProvider).useSupabaseBackend,
  );

  return controller;
});

class FeedController extends StateNotifier<AsyncValue<List<PetPost>>> {
  FeedController({
    FeedRepository? repository,
    AnalyticsService? analytics,
    AsyncValue<List<PetPost>>? initialState,
    List<PetPost>? initialPosts,
    bool loadOnStart = false,
  })  : _posts = _resolveInitialPosts(initialState, initialPosts),
        _analytics = analytics,
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
  final AnalyticsService? _analytics;
  FeedSearchQuery _query = const FeedSearchQuery();

  FeedSearchQuery get query => _query;

  Future<void> refresh() async {
    state = const AsyncValue.loading();

    try {
      final posts = await _repository.fetchPosts(
        limit: _query.hasText ? 100 : 20,
        query: _query,
      );
      _posts = List<PetPost>.unmodifiable(posts);
      state = AsyncValue.data(_posts);
    } catch (error, stackTrace) {
      await _analytics?.trackBackendError(
        operation: 'feed_refresh',
        error: error,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateSearchQuery(String text) async {
    final nextQuery = FeedSearchQuery(text: text);
    if (nextQuery.normalizedText == _query.normalizedText) {
      return;
    }

    _query = nextQuery;
    await _analytics?.track(
      AnalyticsEvent.searchPerformed,
      params: {
        'surface': 'feed',
        'query_length': AnalyticsService.textLengthBucket(text),
        'has_query': nextQuery.hasText,
      },
    );
    await _analytics?.track(
      AnalyticsEvent.feedFilterChanged,
      params: {'has_query': nextQuery.hasText},
    );
    await refresh();
  }

  Future<void> clearSearch() {
    return updateSearchQuery('');
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

  Future<void> addComment(
    String postId,
    String text, {
    AppUser? author,
  }) async {
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

    try {
      final result = await _repository.addComment(
        AddCommentInput(
          postId: postId,
          text: trimmedText,
          authorId: author?.id,
          authorName: author?.displayName ?? author?.email,
        ),
      );
      await _analytics?.track(
        AnalyticsEvent.commentAdded,
        params: {
          'text_length': AnalyticsService.textLengthBucket(trimmedText),
        },
      );

      final syncedPosts = state.asData?.value;
      if (syncedPosts == null) {
        return;
      }

      _setPosts(
        syncedPosts.map((post) {
          if (post.id != result.postId) {
            return post;
          }

          return post.copyWith(
            commentsCount: result.commentsCount,
            comments: post.comments,
          );
        }).toList(growable: false),
      );
    } catch (error, stackTrace) {
      await _analytics?.trackBackendError(
        operation: 'comment_add',
        error: error,
      );
      state = AsyncValue.error(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> createPost({
    required AppUser author,
    required String text,
    PetPost? referencePost,
  }) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      throw ArgumentError('Пост не может быть пустым');
    }

    final posts = state.asData?.value ?? _posts;
    final pet = referencePost ?? (posts.isEmpty ? null : posts.first);
    if (pet == null) {
      throw StateError('Сначала добавьте питомца для публикации.');
    }

    late final PetPost createdPost;
    try {
      createdPost = await _repository.createPost(
        CreatePostInput(
          authorId: author.id,
          authorName: author.displayName ?? author.email ?? 'Владелец',
          petId: pet.petId,
          petName: pet.petName,
          petEmoji: pet.petEmoji,
          imageEmoji: '📷',
          text: trimmedText,
        ),
      );
      await _analytics?.track(
        AnalyticsEvent.postCreated,
        params: {
          'text_length': AnalyticsService.textLengthBucket(trimmedText),
          'has_image': false,
        },
      );
    } catch (error, stackTrace) {
      await _analytics?.trackBackendError(
        operation: 'post_create',
        error: error,
      );
      Error.throwWithStackTrace(error, stackTrace);
    }

    if (_query.matches(createdPost)) {
      _setPosts([createdPost, ...posts]);
    } else {
      _setPosts(posts);
    }
  }

  Future<void> deletePost({
    required PetPost post,
    required AppUser author,
  }) async {
    if (post.authorId != null && post.authorId != author.id) {
      throw ArgumentError('Можно удалить только свой пост.');
    }

    final posts = state.asData?.value ?? _posts;
    try {
      await _repository.deletePost(post.id);
    } catch (error, stackTrace) {
      await _analytics?.trackBackendError(
        operation: 'post_delete',
        error: error,
      );
      Error.throwWithStackTrace(error, stackTrace);
    }

    _setPosts(
      posts.where((candidate) => candidate.id != post.id).toList(
            growable: false,
          ),
    );
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
      if (result.isLiked) {
        await _analytics?.track(AnalyticsEvent.postLiked);
      }

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
      await _analytics?.trackBackendError(
        operation: 'post_like_toggle',
        error: error,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
