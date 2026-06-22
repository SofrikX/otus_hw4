import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/api_error.dart';
import '../../../core/supabase/supabase_error_mapper.dart';
import '../domain/walk.dart';
import '../domain/walks_repository.dart';

class SupabaseWalkRepository implements WalksRepository {
  const SupabaseWalkRepository(
    this._client, {
    String? currentUserId,
  }) : _currentUserIdOverride = currentUserId;

  static const _walkColumns = '''
id,
organizer_name,
title,
place,
scheduled_at,
description,
participants_count
''';

  final SupabaseClient _client;
  final String? _currentUserIdOverride;

  @override
  Future<List<Walk>> fetchWalks({
    int limit = 20,
    WalkFilters filters = const WalkFilters(),
  }) {
    return _guard(() async {
      final userId = _requiredUserId();
      var query =
          _client.from('walks').select(_walkColumns).neq('status', 'cancelled');

      final date = filters.date;
      if (date != null) {
        final start = DateTime(date.year, date.month, date.day);
        final end = start.add(const Duration(days: 1));
        query = query
            .gte('scheduled_at', start.toUtc().toIso8601String())
            .lt('scheduled_at', end.toUtc().toIso8601String());
      }

      final location = filters.normalizedLocationQuery;
      if (location.isNotEmpty) {
        query = query.ilike('place', '%${_escapeIlike(location)}%');
      }

      query = switch (filters.status) {
        WalkStatusFilter.all => query,
        WalkStatusFilter.upcoming =>
          query.gte('scheduled_at', DateTime.now().toUtc().toIso8601String()),
        WalkStatusFilter.completed =>
          query.lt('scheduled_at', DateTime.now().toUtc().toIso8601String()),
      };

      final response = await query.order('scheduled_at', ascending: true).limit(
            limit,
          );

      final walkRows = _rowsFrom(response);
      if (walkRows.isEmpty) {
        return const <Walk>[];
      }

      final walkIds = walkRows.map((row) => row['id'] as String).toList();
      final joinedWalkIds = await _fetchJoinedWalkIds(
        userId: userId,
        walkIds: walkIds,
      );

      return walkRows
          .map(
            (row) => _mapWalk(
              row,
              isJoined: joinedWalkIds.contains(row['id'] as String),
            ),
          )
          .toList(growable: false);
    });
  }

  @override
  Future<Walk> createWalk(CreateWalkInput input) {
    return _guard(() async {
      final user = _requiredUser();
      final response = await _client
          .from('walks')
          .insert({
            'creator_id': user.id,
            'organizer_name': input.organizerName ?? _displayNameFor(user),
            'title': input.title,
            'place': input.place,
            'scheduled_at': input.startsAt.toIso8601String(),
            'description': input.description,
          })
          .select(_walkColumns)
          .single();

      return _mapWalk(response);
    });
  }

  @override
  Future<WalkJoinResult> joinWalk(String walkId) {
    return _guard(() async {
      final userId = _requiredUserId();
      try {
        await _client.from('walk_participants').insert({
          'walk_id': walkId,
          'user_id': userId,
        });
      } on PostgrestException catch (error) {
        if (postgrestCode(error) != '23505') {
          rethrow;
        }

        final walk = await _fetchWalkById(walkId, isJoined: true);
        return WalkJoinResult(
          walkId: walk.id,
          isJoined: true,
          participantsCount: walk.participantCount,
          alreadyJoined: true,
        );
      }

      final walk = await _fetchWalkById(walkId, isJoined: true);
      return WalkJoinResult(
        walkId: walk.id,
        isJoined: true,
        participantsCount: walk.participantCount,
      );
    });
  }

  @override
  Future<WalkJoinResult> leaveWalk(String walkId) {
    return _guard(() async {
      final userId = _requiredUserId();
      await _client
          .from('walk_participants')
          .delete()
          .eq('walk_id', walkId)
          .eq('user_id', userId);

      final walk = await _fetchWalkById(walkId, isJoined: false);
      return WalkJoinResult(
        walkId: walk.id,
        isJoined: false,
        participantsCount: walk.participantCount,
      );
    });
  }

  Future<Set<String>> _fetchJoinedWalkIds({
    required String userId,
    required List<String> walkIds,
  }) async {
    if (walkIds.isEmpty) {
      return const <String>{};
    }

    final response = await _client
        .from('walk_participants')
        .select('walk_id')
        .eq('user_id', userId)
        .inFilter('walk_id', walkIds);

    return _rowsFrom(response).map((row) => row['walk_id'] as String).toSet();
  }

  Future<Walk> _fetchWalkById(
    String walkId, {
    required bool isJoined,
  }) async {
    final response = await _client
        .from('walks')
        .select(_walkColumns)
        .eq('id', walkId)
        .single();

    return _mapWalk(response, isJoined: isJoined);
  }

  Walk _mapWalk(
    Map<String, dynamic> row, {
    bool isJoined = false,
  }) {
    return Walk(
      id: row['id'] as String,
      title: row['title'] as String? ?? 'Прогулка',
      place: row['place'] as String? ?? 'Место уточняется',
      startsAt: DateTime.parse(row['scheduled_at'] as String),
      description: row['description'] as String? ?? '',
      organizerName: row['organizer_name'] as String? ?? 'Организатор',
      participantCount: (row['participants_count'] as num?)?.toInt() ?? 0,
      isJoined: isJoined,
    );
  }

  List<Map<String, dynamic>> _rowsFrom(Object? response) {
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }

    throw const ApiUnexpectedException(
      statusCode: 500,
      code: 'invalid-supabase-response',
      message: 'Supabase returned an unexpected walks response.',
    );
  }

  User _requiredUser() {
    final user = _client.auth.currentUser;
    if (user == null && _currentUserIdOverride == null) {
      throw const ApiUnauthorizedException(
        message: 'Supabase session is required for walk operations.',
      );
    }

    return user ??
        User(
          id: _currentUserIdOverride!,
          appMetadata: const {},
          userMetadata: const {},
          aud: 'authenticated',
          createdAt: DateTime.fromMillisecondsSinceEpoch(0).toIso8601String(),
        );
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

  String _escapeIlike(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    return guardSupabaseOperation<T>(
      operation: 'walks',
      action: action,
    );
  }
}
