import 'pet_post.dart';

abstract class FeedRepository {
  Future<List<PetPost>> fetchPosts({int limit = 20});

  Future<PetPost> createPost(CreatePostInput input);

  Future<PostLikeResult> toggleLike(String postId);
}

class CreatePostInput {
  const CreatePostInput({
    required this.authorId,
    required this.petId,
    required this.text,
    this.authorName,
    this.petName,
    this.petEmoji,
    this.imageEmoji,
    this.imageUrls = const [],
  });

  final String authorId;
  final String petId;
  final String text;
  final String? authorName;
  final String? petName;
  final String? petEmoji;
  final String? imageEmoji;
  final List<String> imageUrls;

  Map<String, Object?> toJson() {
    return {
      'authorId': authorId,
      'petId': petId,
      'text': text,
      'authorName': authorName,
      'petName': petName,
      'petEmoji': petEmoji,
      'imageEmoji': imageEmoji,
      'imageUrls': imageUrls,
    };
  }
}

class PostLikeResult {
  const PostLikeResult({
    required this.postId,
    required this.isLiked,
    required this.likesCount,
  });

  final String postId;
  final bool isLiked;
  final int likesCount;

  factory PostLikeResult.fromJson(Map<String, dynamic> json) {
    return PostLikeResult(
      postId: json['postId'] as String,
      isLiked: json['isLiked'] as bool,
      likesCount: json['likesCount'] as int,
    );
  }
}
