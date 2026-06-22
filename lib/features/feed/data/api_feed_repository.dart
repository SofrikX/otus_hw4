import '../../../core/network/api_client.dart';
import '../domain/feed_repository.dart';
import '../domain/pet_post.dart';

class ApiFeedRepository implements FeedRepository {
  const ApiFeedRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<PetPost>> fetchPosts({
    int limit = 20,
    FeedSearchQuery query = const FeedSearchQuery(),
  }) async {
    final posts = await _apiClient.getPosts(limit: limit);
    return posts.map(_mapPost).where(query.matches).toList(growable: false);
  }

  @override
  Future<PetPost> createPost(CreatePostInput input) async {
    final post = await _apiClient.createPost(input.toJson());
    return _mapPost(post);
  }

  @override
  Future<void> deletePost(String postId) {
    return _apiClient.deletePost(postId);
  }

  @override
  Future<PostLikeResult> toggleLike(String postId) async {
    final result = await _apiClient.togglePostLike(postId);
    return PostLikeResult.fromJson(result);
  }

  @override
  Future<PostCommentResult> addComment(AddCommentInput input) async {
    final result =
        await _apiClient.addPostComment(input.postId, input.toJson());
    return PostCommentResult.fromJson(result);
  }

  PetPost _mapPost(Map<String, dynamic> json) {
    return PetPost(
      id: json['id'] as String,
      // The API can return lean Firestore records; UI-specific fields keep
      // sensible defaults until profile/image enrichment is added.
      petId: json['petId'] as String? ?? '',
      petName: json['petName'] as String? ?? 'Питомец',
      authorName: json['authorName'] as String? ?? 'Владелец',
      authorId: json['authorId'] as String?,
      petEmoji: json['petEmoji'] as String? ?? '🐾',
      imageEmoji: json['imageEmoji'] as String? ?? '📷',
      text: json['text'] as String? ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      comments: (json['comments'] as List<dynamic>? ?? const <dynamic>[])
          .cast<String>(),
    );
  }
}
