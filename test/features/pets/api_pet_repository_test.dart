import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:petconnect/core/network/api_client.dart';
import 'package:petconnect/core/network/auth_token_provider.dart';
import 'package:petconnect/features/pets/data/api_pet_repository.dart';

void main() {
  test('getPetById maps Cloud Functions pet to Pet model', () async {
    final repository = ApiPetRepository(
      _client((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/demo/us-central1/api/pets/pet-1');

        return http.Response(
          jsonEncode({
            'data': {
              'id': 'pet-1',
              'ownerId': 'user-1',
              'ownerName': 'Ava',
              'name': 'Bruno',
              'animalType': 'dog',
              'breed': 'Corgi',
              'age': 3,
              'description': 'Loves parks',
              'photoUrl': 'https://example.test/bruno.jpg',
              'photoEmoji': 'dog',
            },
          }),
          200,
        );
      }),
    );

    final pet = await repository.getPetById('pet-1');

    expect(pet?.id, 'pet-1');
    expect(pet?.name, 'Bruno');
    expect(pet?.ownerName, 'Ava');
    expect(pet?.photoUrl, 'https://example.test/bruno.jpg');
    expect(pet?.age, 3);
  });

  test('getPetsByOwner sends ownerId query to backend API', () async {
    final repository = ApiPetRepository(
      _client((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/demo/us-central1/api/pets');
        expect(request.url.queryParameters['ownerId'], 'user-1');

        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 'pet-1',
                'ownerId': 'user-1',
                'ownerName': 'Ava',
                'name': 'Bruno',
                'animalType': 'dog',
              },
            ],
          }),
          200,
        );
      }),
    );

    final pets = await repository.getPetsByOwner('user-1');

    expect(pets, hasLength(1));
    expect(pets.first.id, 'pet-1');
    expect(pets.first.photoEmoji, '🐾');
  });

  test('getPetById returns null on backend 404', () async {
    final repository = ApiPetRepository(
      _client((_) async {
        return http.Response(
          '{"error":{"code":"not-found","message":"Pet not found."}}',
          404,
        );
      }),
    );

    final pet = await repository.getPetById('missing-pet');

    expect(pet, isNull);
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
