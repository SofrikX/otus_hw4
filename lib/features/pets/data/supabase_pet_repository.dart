import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/api_error.dart';
import '../domain/pet.dart';
import '../domain/pet_repository.dart';

class SupabasePetRepository implements PetRepository {
  const SupabasePetRepository(this._client);

  static const _petColumns = '''
id,
owner_id,
owner_name,
name,
animal_type,
breed,
age,
description,
photo_emoji,
created_at
''';

  final SupabaseClient _client;

  @override
  Future<List<Pet>> fetchPets({int limit = 50}) {
    return _guard(() async {
      final response = await _client
          .from('pets')
          .select(_petColumns)
          .order('created_at', ascending: false)
          .limit(limit);

      return _rowsFrom(response).map(_mapPet).toList(growable: false);
    });
  }

  @override
  Future<Pet?> getPetById(String petId) {
    return _guard(() async {
      final response = await _client
          .from('pets')
          .select(_petColumns)
          .eq('id', petId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return _mapPet(response);
    });
  }

  @override
  Future<List<Pet>> getPetsByOwner(String ownerId) {
    return _guard(() async {
      final response = await _client
          .from('pets')
          .select(_petColumns)
          .eq('owner_id', ownerId)
          .order('created_at', ascending: false);

      return _rowsFrom(response).map(_mapPet).toList(growable: false);
    });
  }

  @override
  Future<Pet> createPet(CreatePetInput input) {
    return _guard(() async {
      final userId = _requiredUserId();
      if (input.ownerId != userId) {
        throw const ApiForbiddenException(
          message: 'Only the current owner can create this pet profile.',
        );
      }

      final response = await _client
          .from('pets')
          .insert({
            'owner_id': userId,
            if (input.ownerName != null) 'owner_name': input.ownerName,
            'name': input.name,
            'animal_type': input.animalType,
            'breed': input.breed,
            'age': input.age,
            'description': input.description,
            if (input.photoEmoji != null) 'photo_emoji': input.photoEmoji,
          })
          .select(_petColumns)
          .single();

      return _mapPet(response);
    });
  }

  Pet _mapPet(Map<String, dynamic> row) {
    return Pet(
      id: row['id'] as String,
      ownerId: row['owner_id'] as String,
      name: row['name'] as String? ?? 'Питомец',
      animalType: row['animal_type'] as String? ?? 'other',
      breed: row['breed'] as String? ?? 'Не указана',
      age: (row['age'] as num?)?.toInt() ?? 0,
      description: row['description'] as String? ?? '',
      photoEmoji: row['photo_emoji'] as String? ?? '🐾',
      ownerName: row['owner_name'] as String? ?? 'Владелец',
    );
  }

  List<Map<String, dynamic>> _rowsFrom(Object? response) {
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }

    throw const ApiUnexpectedException(
      statusCode: 500,
      code: 'invalid-supabase-response',
      message: 'Supabase returned an unexpected pets response.',
    );
  }

  String _requiredUserId() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const ApiUnauthorizedException(
        message: 'Supabase session is required for pet operations.',
      );
    }

    return user.id;
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException {
      rethrow;
    } on AuthException catch (error) {
      throw ApiUnauthorizedException(message: error.message);
    } on PostgrestException catch (error) {
      throw _mapPostgrestException(error);
    } on FormatException catch (error) {
      throw ApiUnexpectedException(
        statusCode: 500,
        code: 'invalid-supabase-response',
        message: error.message,
      );
    } on Object catch (error) {
      if (error is Error) {
        rethrow;
      }

      throw const ApiNetworkException();
    }
  }

  ApiException _mapPostgrestException(PostgrestException error) {
    final code = _postgrestCode(error);
    if (code == '42501') {
      return ApiForbiddenException(message: error.message, code: code);
    }
    if (code == '23505' ||
        code == '23503' ||
        code == '23514' ||
        code == '22P02') {
      return ApiValidationException(message: error.message, code: code);
    }
    if (code == 'PGRST116' || code == '406') {
      return ApiNotFoundException(message: error.message, code: code);
    }
    if (code == '401' || code == 'PGRST301') {
      return ApiUnauthorizedException(message: error.message, code: code);
    }

    return ApiUnexpectedException(
      statusCode: 500,
      code: code,
      message: error.message,
    );
  }

  String _postgrestCode(PostgrestException error) {
    final message = error.message;
    try {
      final decoded = jsonDecode(message);
      if (decoded is Map<String, dynamic>) {
        final code = decoded['code'] as String?;
        if (code != null && code.isNotEmpty) {
          return code;
        }
      }
    } on FormatException {
      // Supabase can also provide a plain-text message.
    }

    return error.code ?? 'postgrest-error';
  }
}
