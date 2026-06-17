import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:petconnect/core/network/api_error.dart';
import 'package:petconnect/features/walks/data/supabase_walk_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('fetchWalks maps Supabase walks rows and joined state', () async {
    final seenPaths = <String>[];
    final repository = SupabaseWalkRepository(
      _client((request) async {
        seenPaths.add(request.url.path);

        if (request.url.path == '/rest/v1/walks') {
          expect(request.method, 'GET');
          expect(request.url.queryParameters['status'], 'eq.active');
          expect(request.url.queryParameters['limit'], '2');

          return _jsonResponse(
            request,
            [
              {
                'id': 'walk-1',
                'title': 'Corgi meetup',
                'place': 'Gorky Park',
                'scheduled_at': '2026-06-18T09:30:00Z',
                'description': 'Morning social walk',
                'organizer_name': 'Ava',
                'participants_count': 6,
              },
            ],
          );
        }

        expect(request.url.path, '/rest/v1/walk_participants');
        expect(request.method, 'GET');
        expect(request.url.queryParameters['user_id'], 'eq.user-1');

        return _jsonResponse(
          request,
          [
            {'walk_id': 'walk-1'},
          ],
        );
      }),
      currentUserId: 'user-1',
    );

    final walks = await repository.fetchWalks(limit: 2);

    expect(seenPaths, ['/rest/v1/walks', '/rest/v1/walk_participants']);
    expect(walks, hasLength(1));
    expect(walks.first.id, 'walk-1');
    expect(walks.first.title, 'Corgi meetup');
    expect(walks.first.participantCount, 6);
    expect(walks.first.isJoined, isTrue);
  });

  test('joinWalk inserts walk participant and returns updated count', () async {
    final seenPaths = <String>[];
    final repository = SupabaseWalkRepository(
      _client((request) async {
        seenPaths.add(request.url.path);

        if (request.url.path == '/rest/v1/walk_participants') {
          expect(request.method, 'POST');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['walk_id'], 'walk-1');
          expect(body['user_id'], 'user-1');

          return _jsonResponse(request, [], 201);
        }

        expect(request.url.path, '/rest/v1/walks');
        expect(request.url.queryParameters['id'], 'eq.walk-1');

        return _jsonResponse(
          request,
          {
            'id': 'walk-1',
            'title': 'Corgi meetup',
            'place': 'Gorky Park',
            'scheduled_at': '2026-06-18T09:30:00Z',
            'description': 'Morning social walk',
            'organizer_name': 'Ava',
            'participants_count': 7,
          },
        );
      }),
      currentUserId: 'user-1',
    );

    final result = await repository.joinWalk('walk-1');

    expect(seenPaths, ['/rest/v1/walk_participants', '/rest/v1/walks']);
    expect(result.walkId, 'walk-1');
    expect(result.isJoined, isTrue);
    expect(result.participantsCount, 7);
    expect(result.alreadyJoined, isFalse);
  });

  test('joinWalk maps unique constraint to already joined result', () async {
    final repository = SupabaseWalkRepository(
      _client((request) async {
        if (request.url.path == '/rest/v1/walk_participants') {
          return _jsonResponse(
            request,
            {
              'code': '23505',
              'message':
                  'duplicate key value violates unique constraint "walk_participants_walk_id_user_id_key"',
              'details': null,
              'hint': null,
            },
            409,
          );
        }

        return _jsonResponse(
          request,
          {
            'id': 'walk-1',
            'title': 'Corgi meetup',
            'place': 'Gorky Park',
            'scheduled_at': '2026-06-18T09:30:00Z',
            'description': 'Morning social walk',
            'organizer_name': 'Ava',
            'participants_count': 7,
          },
        );
      }),
      currentUserId: 'user-1',
    );

    final result = await repository.joinWalk('walk-1');

    expect(result.isJoined, isTrue);
    expect(result.alreadyJoined, isTrue);
    expect(result.participantsCount, 7);
  });

  test('fetchWalks maps RLS denial to forbidden ApiException', () async {
    final repository = SupabaseWalkRepository(
      _client((request) async {
        return _jsonResponse(
          request,
          {
            'code': '42501',
            'message': 'permission denied for table walks',
            'details': null,
            'hint': null,
          },
          403,
        );
      }),
      currentUserId: 'user-1',
    );

    expect(
      () => repository.fetchWalks(),
      throwsA(
        isA<ApiForbiddenException>()
            .having((error) => error.code, 'code', '42501'),
      ),
    );
  });
}

SupabaseClient _client(Future<http.Response> Function(http.Request) handler) {
  return SupabaseClient(
    'https://example.supabase.co',
    'anon-key',
    httpClient: MockClient(handler),
  );
}

http.Response _jsonResponse(
  http.Request request,
  Object body, [
  int statusCode = 200,
]) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    statusCode,
    headers: {'content-type': 'application/json; charset=utf-8'},
    request: request,
  );
}
