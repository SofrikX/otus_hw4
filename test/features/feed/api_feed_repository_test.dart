import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:petconnect/core/network/api_client.dart';
import 'package:petconnect/core/network/auth_token_provider.dart';
import 'package:petconnect/features/feed/data/api_feed_repository.dart';
import 'package:petconnect/features/feed/domain/feed_repository.dart';

void main() {
  test('fetchPosts maps Cloud Functions posts to PetPost models', () async {
    final repository = ApiFeedRepository(
      _client((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/demo/us-central1/api/posts');
        expect(request.url.queryParameters['limit'], '5');

        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 'post-1',
                'authorId': 'user-1',
                'petId': 'pet-1',
                'text': 'Sunny walk',
                'likesCount': 7,
                'commentsCount': 2,
                'createdAt': '2026-06-16T09:30:00.000Z',
              },
            ],
          }),
          200,
        );
      }),
    );

    final posts = await repository.fetchPosts(limit: 5);

    expect(posts, hasLength(1));
    expect(posts.first.id, 'post-1');
    expect(posts.first.text, 'Sunny walk');
    expect(posts.first.likesCount, 7);
    expect(posts.first.commentsCount, 2);
    expect(posts.first.isLiked, isFalse);
  });

  test('createPost sends repository input to backend API', () async {
    Map<String, dynamic>? requestBody;
    final repository = ApiFeedRepository(
      _client((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/demo/us-central1/api/posts');
        requestBody = jsonDecode(request.body) as Map<String, dynamic>;

        return http.Response(
          jsonEncode({
            'data': {
              'id': 'post-2',
              'authorId': 'user-1',
              'petId': 'pet-1',
              'authorName': 'Ava',
              'petName': 'Bruno',
              'text': 'New post',
              'likesCount': 0,
              'commentsCount': 0,
              'createdAt': '2026-06-16T10:00:00.000Z',
            },
          }),
          200,
        );
      }),
    );

    final post = await repository.createPost(
      const CreatePostInput(
        authorId: 'user-1',
        petId: 'pet-1',
        text: 'New post',
        authorName: 'Ava',
        petName: 'Bruno',
      ),
    );

    expect(requestBody?['authorId'], 'user-1');
    expect(requestBody?['petId'], 'pet-1');
    expect(requestBody?['text'], 'New post');
    expect(post.id, 'post-2');
    expect(post.petName, 'Bruno');
  });

  test('toggleLike maps backend like result', () async {
    final repository = ApiFeedRepository(
      _client((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/demo/us-central1/api/posts/post-1/like');

        return http.Response(
          jsonEncode({
            'data': {
              'postId': 'post-1',
              'isLiked': true,
              'likesCount': 8,
            },
          }),
          200,
        );
      }),
    );

    final result = await repository.toggleLike('post-1');

    expect(result.postId, 'post-1');
    expect(result.isLiked, isTrue);
    expect(result.likesCount, 8);
  });
}

ApiClient _client(Future<http.Response> Function(http.Request) handler) {
  return ApiClient(
    baseUri: Uri.parse('http://127.0.0.1:5001/demo/us-central1/api'),
    httpClient: MockClient(handler),
    authTokenProvider: const _FakeAuthTokenProvider('token-123'),
  );
}

class _FakeAuthTokenProvider implements AuthTokenProvider {
  const _FakeAuthTokenProvider(this._token);

  final String? _token;

  @override
  Future<String?> getToken() async => _token;
}
