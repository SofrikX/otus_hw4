import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/api_error.dart';
import '../../../core/supabase/supabase_error_mapper.dart';
import '../domain/feed_repository.dart';
import '../domain/pet_post.dart';

class SupabaseFeedRepository implements FeedRepository {
  const SupabaseFeedRepository(this._client);

  static const _postColumns = '''
id,
pet_id,
pet_name,
author_name,
pet_emoji,
image_emoji,
text,
created_at,
likes_count,
comments_count
''';

  final SupabaseClient _client;

  @override
  Future<List<PetPost>> fetchPosts({int limit = 20}) {
    return _guard(() async {
      final userId = _requiredUserId();
      final response = await _client
          .from('posts')
          .select(_postColumns)
          .eq('visibility', 'public')
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .limit(limit);

      final postRows = _rowsFrom(response);
      if (postRows.isEmpty) {
        return const <PetPost>[];
      }

      final postIds = postRows.map((row) => row['id'] as String).toList();
      final likedPostIds = await _fetchLikedPostIds(
        userId: userId,
        postIds: postIds,
      );
      final commentsByPostId = await _fetchCommentsByPostId(postIds);

      return postRows
          .map(
            (row) => _mapPost(
              row,
              isLiked: likedPostIds.contains(row['id'] as String),
              comments: commentsByPostId[row['id'] as String] ?? const [],
            ),
          )
          .toList(growable: false);
    });
  }

  @override
  Future<PetPost> createPost(CreatePostInput input) {
    return _guard(() async {
      final user = _requiredUser();
      final response = await _client
          .from('posts')
          .insert({
            'author_id': user.id,
            'author_name': input.authorName ?? _displayNameFor(user),
            'pet_id': input.petId,
            if (input.petName != null) 'pet_name': input.petName,
            if (input.petEmoji != null) 'pet_emoji': input.petEmoji,
            'text': input.text,
            'image_urls': input.imageUrls,
            if (input.imageEmoji != null) 'image_emoji': input.imageEmoji,
          })
          .select(_postColumns)
          .single();

      return _mapPost(response);
    });
  }

  @override
  Future<PostLikeResult> toggleLike(String postId) {
    return _guard(() async {
      final userId = _requiredUserId();
      final existingLike = await _client
          .from('post_likes')
          .select('id')
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();

      final isLiked = existingLike == null;
      if (isLiked) {
        await _client.from('post_likes').insert({
          'post_id': postId,
          'user_id': userId,
        });
      } else {
        await _client
            .from('post_likes')
            .delete()
            .eq('id', existingLike['id'] as String);
      }

      final post = await _fetchPostById(postId);
      return PostLikeResult(
        postId: post.id,
        isLiked: isLiked,
        likesCount: post.likesCount,
      );
    });
  }

  @override
  Future<PostCommentResult> addComment(AddCommentInput input) {
    return _guard(() async {
      final user = _requiredUser();
      final insertedComment = await _client
          .from('comments')
          .insert({
            'post_id': input.postId,
            'author_id': user.id,
            'author_name': input.authorName ?? _displayNameFor(user),
            'text': input.text,
          })
          .select('text')
          .single();

      final post = await _fetchPostById(input.postId);
      return PostCommentResult(
        postId: post.id,
        text: insertedComment['text'] as String? ?? input.text,
        commentsCount: post.commentsCount,
      );
    });
  }

  Future<PetPost> _fetchPostById(String postId) async {
    final response = await _client
        .from('posts')
        .select(_postColumns)
        .eq('id', postId)
        .isFilter('deleted_at', null)
        .single();

    final userId = _requiredUserId();
    final likedPostIds = await _fetchLikedPostIds(
      userId: userId,
      postIds: [postId],
    );
    final commentsByPostId = await _fetchCommentsByPostId([postId]);

    return _mapPost(
      response,
      isLiked: likedPostIds.contains(postId),
      comments: commentsByPostId[postId] ?? const [],
    );
  }

  Future<Set<String>> _fetchLikedPostIds({
    required String userId,
    required List<String> postIds,
  }) async {
    if (postIds.isEmpty) {
      return const <String>{};
    }

    final response = await _client
        .from('post_likes')
        .select('post_id')
        .eq('user_id', userId)
        .inFilter('post_id', postIds);

    return _rowsFrom(response).map((row) => row['post_id'] as String).toSet();
  }

  Future<Map<String, List<String>>> _fetchCommentsByPostId(
    List<String> postIds,
  ) async {
    if (postIds.isEmpty) {
      return const <String, List<String>>{};
    }

    final response = await _client
        .from('comments')
        .select('post_id,text,created_at')
        .inFilter('post_id', postIds)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: true);

    final commentsByPostId = <String, List<String>>{};
    for (final row in _rowsFrom(response)) {
      final postId = row['post_id'] as String;
      final text = row['text'] as String? ?? '';
      if (text.trim().isEmpty) {
        continue;
      }

      commentsByPostId.putIfAbsent(postId, () => <String>[]).add(text);
    }

    return commentsByPostId.map(
      (postId, comments) => MapEntry(
        postId,
        List<String>.unmodifiable(comments),
      ),
    );
  }

  PetPost _mapPost(
    Map<String, dynamic> row, {
    bool isLiked = false,
    List<String> comments = const [],
  }) {
    return PetPost(
      id: row['id'] as String,
      petId: row['pet_id'] as String,
      petName: row['pet_name'] as String? ?? 'Питомец',
      authorName: row['author_name'] as String? ?? 'Владелец',
      petEmoji: row['pet_emoji'] as String? ?? '🐾',
      imageEmoji: row['image_emoji'] as String? ?? '📷',
      text: row['text'] as String? ?? '',
      createdAt: DateTime.parse(row['created_at'] as String),
      likesCount: row['likes_count'] as int? ?? 0,
      commentsCount: row['comments_count'] as int? ?? comments.length,
      isLiked: isLiked,
      comments: comments,
    );
  }

  List<Map<String, dynamic>> _rowsFrom(Object? response) {
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }

    throw const ApiUnexpectedException(
      statusCode: 500,
      code: 'invalid-supabase-response',
      message: 'Supabase returned an unexpected response.',
    );
  }

  User _requiredUser() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const ApiUnauthorizedException(
        message: 'Supabase session is required for feed operations.',
      );
    }

    return user;
  }

  String _requiredUserId() => _requiredUser().id;

  String _displayNameFor(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final displayName = metadata['display_name'] as String? ??
        metadata['name'] as String? ??
        metadata['full_name'] as String?;

    final trimmedDisplayName = displayName?.trim();
    if (trimmedDisplayName != null && trimmedDisplayName.isNotEmpty) {
      return trimmedDisplayName;
    }

    return user.email ?? 'Владелец';
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    return guardSupabaseOperation<T>(
      operation: 'feed',
      action: action,
    );
  }
}
