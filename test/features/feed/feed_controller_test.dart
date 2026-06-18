import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petconnect/core/config/backend_config.dart';
import 'package:petconnect/core/data/mock_data.dart';
import 'package:petconnect/core/supabase/supabase_client_provider.dart';
import 'package:petconnect/features/auth/domain/app_user.dart';
import 'package:petconnect/features/feed/application/feed_controller.dart';
import 'package:petconnect/features/feed/data/mock_feed_repository.dart';
import 'package:petconnect/features/feed/data/supabase_feed_repository.dart';
import 'package:petconnect/features/feed/domain/feed_repository.dart';
import 'package:petconnect/features/feed/domain/pet_post.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('refresh loads feed from repository', () async {
    final controller = FeedController(
      repository: _FakeFeedRepository(posts: [mockPosts.first]),
      initialState: const AsyncValue<List<PetPost>>.loading(),
      initialPosts: const [],
    );

    await controller.refresh();

    expect(controller.state.hasValue, isTrue);
    expect(controller.state.value, [mockPosts.first]);
  });

  test('refresh exposes backend error state', () async {
    final controller = FeedController(
      repository: _FakeFeedRepository(fetchError: Exception('Backend down')),
      initialState: const AsyncValue<List<PetPost>>.loading(),
      initialPosts: const [],
    );

    await controller.refresh();

    expect(controller.state.hasError, isTrue);
    expect(controller.state.error.toString(), contains('Backend down'));
  });

  test('toggleLike updates post like state in mock feed state', () async {
    final controller = FeedController();
    final post = mockPosts.first;

    controller.toggleLike(post.id);
    await Future<void>.delayed(Duration.zero);

    final updatedPost = _firstPost(controller);
    expect(updatedPost?.isLiked, isTrue);
    expect(updatedPost?.likesCount, post.likesCount + 1);
  });

  test('addComment stores comment text in mock feed state', () async {
    const comment = 'Бруно отлично справился!';
    final controller = FeedController();
    final post = mockPosts.first;

    await controller.addComment(post.id, comment);

    final updatedPost = _firstPost(controller);
    expect(updatedPost?.commentsCount, post.commentsCount + 1);
    expect(updatedPost?.comments.last, comment);
  });

  test('addComment exposes backend error state', () async {
    final post = mockPosts.first;
    final controller = FeedController(
      repository: _FakeFeedRepository(
        posts: [post],
        commentError: Exception('Comment failed'),
      ),
      initialPosts: [post],
    );

    await expectLater(
      controller.addComment(post.id, 'Комментарий'),
      throwsA(isA<Exception>()),
    );

    expect(controller.state.hasError, isTrue);
    expect(controller.state.error.toString(), contains('Comment failed'));
  });

  test('createPost prepends post returned by repository', () async {
    const createdText = 'Новый пост из UI';
    final controller = FeedController(
      repository: _FakeFeedRepository(posts: [mockPosts.first]),
      initialPosts: [mockPosts.first],
    );

    await controller.createPost(
      author: const AppUser(
        id: 'user-qa',
        email: 'qa@example.com',
        displayName: 'QA User',
      ),
      text: createdText,
    );

    final createdPost = _firstPost(controller);
    expect(createdPost?.id, 'created-post');
    expect(createdPost?.text, createdText);
    expect(controller.state.value, hasLength(2));
  });

  test('feedRepositoryProvider uses mock repository by default', () {
    final container = ProviderContainer(
      overrides: [
        backendConfigProvider.overrideWithValue(
          const BackendConfig(baseUrl: '', useFirebaseBackend: false),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(feedRepositoryProvider), isA<MockFeedRepository>());
  });

  test(
      'feedRepositoryProvider uses Supabase repository when backend is enabled',
      () {
    final container = ProviderContainer(
      overrides: [
        backendConfigProvider.overrideWithValue(
          const BackendConfig(
            baseUrl: '',
            useSupabaseBackend: true,
            supabaseUrl: 'https://example.supabase.co',
            supabasePublishableKey: 'publishable-key',
          ),
        ),
        supabaseClientProvider.overrideWithValue(
          SupabaseClient('https://example.supabase.co', 'publishable-key'),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(feedRepositoryProvider),
      isA<SupabaseFeedRepository>(),
    );
  });
}

PetPost? _firstPost(FeedController controller) {
  return controller.state.when(
    data: (posts) => posts.first,
    error: (_, __) => null,
    loading: () => null,
  );
}

class _FakeFeedRepository implements FeedRepository {
  const _FakeFeedRepository({
    this.posts = const [],
    this.fetchError,
    this.commentError,
  });

  final List<PetPost> posts;
  final Object? fetchError;
  final Object? commentError;

  @override
  Future<List<PetPost>> fetchPosts({int limit = 20}) async {
    final error = fetchError;
    if (error != null) {
      throw error;
    }

    return posts.take(limit).toList(growable: false);
  }

  @override
  Future<PetPost> createPost(CreatePostInput input) async {
    return PetPost(
      id: 'created-post',
      petId: input.petId,
      petName: input.petName ?? 'Питомец',
      authorName: input.authorName ?? 'Владелец',
      petEmoji: input.petEmoji ?? '🐾',
      imageEmoji: input.imageEmoji ?? '📷',
      text: input.text,
      createdAt: DateTime(2026),
      likesCount: 0,
      commentsCount: 0,
      isLiked: false,
    );
  }

  @override
  Future<PostLikeResult> toggleLike(String postId) async {
    final post = posts.firstWhere(
      (post) => post.id == postId,
      orElse: () => mockPosts.firstWhere((post) => post.id == postId),
    );

    return PostLikeResult(
      postId: post.id,
      isLiked: !post.isLiked,
      likesCount: post.likesCount + (post.isLiked ? -1 : 1),
    );
  }

  @override
  Future<PostCommentResult> addComment(AddCommentInput input) async {
    final error = commentError;
    if (error != null) {
      throw error;
    }

    final post = posts.firstWhere(
      (post) => post.id == input.postId,
      orElse: () => mockPosts.firstWhere((post) => post.id == input.postId),
    );
    return PostCommentResult(
      postId: post.id,
      text: input.text,
      commentsCount: post.commentsCount + 1,
    );
  }
}
