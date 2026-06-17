import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:petconnect/core/config/backend_config.dart';
import 'package:petconnect/core/network/api_error.dart';
import 'package:petconnect/core/supabase/supabase_client_provider.dart';
import 'package:petconnect/features/pets/application/pets_provider.dart';
import 'package:petconnect/features/pets/data/mock_pet_repository.dart';
import 'package:petconnect/features/pets/data/supabase_pet_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('getPetById maps Supabase pets row to Pet model', () async {
    final repository = SupabasePetRepository(
      _client((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/rest/v1/pets');
        expect(request.url.queryParameters['id'], 'eq.pet-1');

        return _jsonResponse(
          request,
          [
            {
              'id': 'pet-1',
              'owner_id': 'user-1',
              'owner_name': 'Ava',
              'name': 'Bruno',
              'animal_type': 'dog',
              'breed': 'Corgi',
              'age': 3,
              'description': 'Loves parks',
              'photo_emoji': '🐶',
              'created_at': '2026-06-17T10:00:00Z',
            },
          ],
        );
      }),
    );

    final pet = await repository.getPetById('pet-1');

    expect(pet?.id, 'pet-1');
    expect(pet?.ownerId, 'user-1');
    expect(pet?.name, 'Bruno');
    expect(pet?.ownerName, 'Ava');
    expect(pet?.photoEmoji, '🐶');
  });

  test('getPetById returns null when Supabase returns no row', () async {
    final repository = SupabasePetRepository(
      _client((request) async {
        expect(request.url.queryParameters['id'], 'eq.missing-pet');
        return _jsonResponse(request, []);
      }),
    );

    final pet = await repository.getPetById('missing-pet');

    expect(pet, isNull);
  });

  test('getPetById maps RLS denial to forbidden ApiException', () async {
    final repository = SupabasePetRepository(
      _client((request) async {
        return _jsonResponse(
          request,
          {
            'code': '42501',
            'message': 'new row violates row-level security policy',
            'details': null,
            'hint': null,
          },
          403,
        );
      }),
    );

    expect(
      () => repository.getPetById('pet-1'),
      throwsA(
        isA<ApiForbiddenException>()
            .having((error) => error.code, 'code', '42501'),
      ),
    );
  });

  test('getPetsByOwner sends owner_id filter to Supabase', () async {
    http.Request? capturedRequest;
    final repository = SupabasePetRepository(
      _client((request) async {
        capturedRequest = request;

        return _jsonResponse(
          request,
          [
            {
              'id': 'pet-1',
              'owner_id': 'user-1',
              'owner_name': 'Ava',
              'name': 'Bruno',
              'animal_type': 'dog',
              'breed': null,
              'age': null,
              'description': null,
              'photo_emoji': null,
              'created_at': '2026-06-17T10:00:00Z',
            },
          ],
        );
      }),
    );

    final pets = await repository.getPetsByOwner('user-1');

    expect(pets, hasLength(1));
    expect(pets.first.breed, 'Не указана');
    expect(pets.first.photoEmoji, '🐾');
    expect(capturedRequest?.method, 'GET');
    expect(capturedRequest?.url.path, '/rest/v1/pets');
    expect(capturedRequest?.url.queryParameters['owner_id'], 'eq.user-1');
    expect(
      capturedRequest?.url.queryParameters['order'],
      'created_at.desc.nullslast',
    );
  });

  test('petRepositoryProvider uses Supabase repository in backend mode', () {
    final container = ProviderContainer(
      overrides: [
        backendConfigProvider.overrideWithValue(
          const BackendConfig(
            baseUrl: '',
            useSupabaseBackend: true,
            supabaseUrl: 'https://example.supabase.co',
            supabaseAnonKey: 'anon-key',
          ),
        ),
        supabaseClientProvider.overrideWithValue(
          _client((_) async => http.Response('[]', 200)),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(petRepositoryProvider), isA<SupabasePetRepository>());
  });

  test('petRepositoryProvider keeps mock fallback when backend mode is off',
      () {
    final container = ProviderContainer(
      overrides: [
        backendConfigProvider.overrideWithValue(
          const BackendConfig(baseUrl: ''),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(petRepositoryProvider), isA<MockPetRepository>());
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
