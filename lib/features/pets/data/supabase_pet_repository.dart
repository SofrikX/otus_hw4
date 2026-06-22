import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/api_error.dart';
import '../../../core/supabase/supabase_error_mapper.dart';
import '../domain/pet.dart';
import '../domain/pet_repository.dart';

class SupabasePetRepository implements PetRepository {
  const SupabasePetRepository(this._client);

  static const petImagesBucket = 'pet-images';

  static const _petColumns = '''
id,
owner_id,
owner_name,
name,
animal_type,
breed,
age,
description,
photo_url,
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

  @override
  Future<Pet> updatePet(UpdatePetInput input) {
    return _guard(() async {
      final userId = _requiredUserId();
      final petRow = await _client
          .from('pets')
          .select('id, owner_id')
          .eq('id', input.petId)
          .single();

      if (petRow['owner_id'] != userId) {
        throw const ApiForbiddenException(
          message: 'Only the pet owner can update this profile.',
        );
      }

      final response = await _client
          .from('pets')
          .update({
            'name': input.name,
            'animal_type': input.animalType,
            'breed': input.breed,
            'age': input.age,
            'description': input.description,
            if (input.photoEmoji != null) 'photo_emoji': input.photoEmoji,
          })
          .eq('id', input.petId)
          .select(_petColumns)
          .single();

      return _mapPet(response);
    });
  }

  @override
  Future<void> deletePet(String petId) {
    return _guard(() async {
      final userId = _requiredUserId();
      final petRow = await _client
          .from('pets')
          .select('id, owner_id')
          .eq('id', petId)
          .single();

      if (petRow['owner_id'] != userId) {
        throw const ApiForbiddenException(
          message: 'Only the pet owner can delete this profile.',
        );
      }

      await _client.from('pets').delete().eq('id', petId);
    });
  }

  @override
  Future<Pet> uploadPetPhoto(UploadPetPhotoInput input) {
    return _guard(() async {
      final userId = _requiredUserId();
      final petRow = await _client
          .from('pets')
          .select('id, owner_id')
          .eq('id', input.petId)
          .single();

      if (petRow['owner_id'] != userId) {
        throw const ApiForbiddenException(
          message: 'Only the pet owner can update this photo.',
        );
      }

      final safeFileName = _safeStorageFileName(input.fileName);
      final storagePath =
          '$userId/${input.petId}/${DateTime.now().microsecondsSinceEpoch}-$safeFileName';

      await _client.storage.from(petImagesBucket).uploadBinary(
            storagePath,
            input.bytes,
            fileOptions: FileOptions(
              cacheControl: '3600',
              contentType: input.contentType,
              upsert: true,
            ),
          );

      final publicUrl =
          _client.storage.from(petImagesBucket).getPublicUrl(storagePath);

      final response = await _client
          .from('pets')
          .update({'photo_url': publicUrl})
          .eq('id', input.petId)
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
      photoUrl: row['photo_url'] as String?,
      photoEmoji: row['photo_emoji'] as String? ?? '🐾',
      ownerName: row['owner_name'] as String? ?? 'Владелец',
    );
  }

  String _safeStorageFileName(String fileName) {
    final trimmed = fileName.trim().toLowerCase();
    final sanitized = trimmed.replaceAll(RegExp(r'[^a-z0-9._-]'), '-');
    final withoutRuns = sanitized.replaceAll(RegExp('-+'), '-');
    final result = withoutRuns.isEmpty ? 'pet-photo.jpg' : withoutRuns;
    return result.length > 96 ? result.substring(result.length - 96) : result;
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
    return guardSupabaseOperation<T>(
      operation: 'pets',
      action: action,
    );
  }
}
