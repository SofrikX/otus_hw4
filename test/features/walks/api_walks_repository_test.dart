import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:petconnect/core/network/api_client.dart';
import 'package:petconnect/core/network/auth_token_provider.dart';
import 'package:petconnect/features/walks/data/api_walks_repository.dart';

void main() {
  test('fetchWalks maps Cloud Functions walks to Walk models', () async {
    final repository = ApiWalksRepository(
      _client((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/demo/us-central1/api/walks');
        expect(request.url.queryParameters['limit'], '5');

        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 'walk-1',
                'title': 'Corgi meetup',
                'place': 'Gorky Park',
                'startsAt': '2026-06-25T09:30:00.000Z',
                'description': 'Morning social walk',
                'organizerName': 'Ava',
                'participantsCount': 6,
                'isJoined': false,
              },
            ],
          }),
          200,
        );
      }),
    );

    final walks = await repository.fetchWalks(limit: 5);

    expect(walks, hasLength(1));
    expect(walks.first.id, 'walk-1');
    expect(walks.first.title, 'Corgi meetup');
    expect(walks.first.participantCount, 6);
    expect(walks.first.isJoined, isFalse);
  });

  test('joinWalk maps backend join result', () async {
    final repository = ApiWalksRepository(
      _client((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/demo/us-central1/api/walks/walk-1/join');

        return http.Response(
          jsonEncode({
            'data': {
              'walkId': 'walk-1',
              'isJoined': true,
              'participantsCount': 7,
            },
          }),
          200,
        );
      }),
    );

    final result = await repository.joinWalk('walk-1');

    expect(result.walkId, 'walk-1');
    expect(result.isJoined, isTrue);
    expect(result.participantsCount, 7);
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
