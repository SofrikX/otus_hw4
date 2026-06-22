import '../../../core/data/mock_data.dart';
import '../domain/feed_repository.dart';
import '../domain/pet_post.dart';

class MockFeedRepository implements FeedRepository {
  MockFeedRepository({List<PetPost>? initialPosts})
      : _posts = List<PetPost>.unmodifiable(initialPosts ?? mockPosts);

  List<PetPost> _posts;

  @override
  Future<List<PetPost>> fetchPosts({
    int limit = 20,
    FeedSearchQuery query = const FeedSearchQuery(),
  }) async {
    return _posts.where(query.matches).take(limit).toList(growable: false);
  }

  @override
  Future<PetPost> createPost(CreatePostInput input) async {
    final post = PetPost(
      id: 'mock-post-${_posts.length + 1}',
      petId: input.petId,
      petName: input.petName ?? 'Питомец',
      authorName: input.authorName ?? 'Владелец',
      authorId: input.authorId,
      petEmoji: input.petEmoji ?? '🐾',
      imageEmoji: input.imageEmoji ?? '📷',
      text: input.text,
      createdAt: DateTime.now(),
      likesCount: 0,
      commentsCount: 0,
      isLiked: false,
    );

    _posts = List<PetPost>.unmodifiable([post, ..._posts]);
    return post;
  }

  @override
  Future<void> deletePost(String postId) async {
    final before = _posts.length;
    _posts = _posts.where((post) => post.id != postId).toList(growable: false);
    if (_posts.length == before) {
      throw ArgumentError('Post not found: $postId');
    }
  }

  @override
  Future<PostLikeResult> toggleLike(String postId) async {
    PetPost? updatedPost;
    _posts = _posts.map((post) {
      if (post.id != postId) {
        return post;
      }

      final nextIsLiked = !post.isLiked;
      final nextLikesCount = post.likesCount + (nextIsLiked ? 1 : -1);
      updatedPost = post.copyWith(
        isLiked: nextIsLiked,
        likesCount: nextLikesCount < 0 ? 0 : nextLikesCount,
      );

      return updatedPost!;
    }).toList(growable: false);

    final post = updatedPost;
    if (post == null) {
      throw ArgumentError('Post not found: $postId');
    }

    return PostLikeResult(
      postId: post.id,
      isLiked: post.isLiked,
      likesCount: post.likesCount,
    );
  }

  @override
  Future<PostCommentResult> addComment(AddCommentInput input) async {
    final trimmedText = input.text.trim();
    if (trimmedText.isEmpty) {
      throw ArgumentError('Комментарий не может быть пустым');
    }

    PetPost? updatedPost;
    _posts = _posts.map((post) {
      if (post.id != input.postId) {
        return post;
      }

      updatedPost = post.copyWith(
        commentsCount: post.commentsCount + 1,
        comments: List<String>.unmodifiable([
          ...post.comments,
          trimmedText,
        ]),
      );

      return updatedPost!;
    }).toList(growable: false);

    final post = updatedPost;
    if (post == null) {
      throw ArgumentError('Post not found: ${input.postId}');
    }

    return PostCommentResult(
      postId: post.id,
      text: trimmedText,
      commentsCount: post.commentsCount,
    );
  }
}
