import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../../core/config/backend_config.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/network/api_client.dart';
import '../../../core/supabase/supabase_client_provider.dart';
import '../../auth/domain/app_user.dart';
import '../data/api_walks_repository.dart';
import '../data/mock_walks_repository.dart';
import '../data/supabase_walk_repository.dart';
import '../domain/walk.dart';
import '../domain/walks_repository.dart';

final walksRepositoryProvider = Provider<WalksRepository>((ref) {
  final config = ref.watch(backendConfigProvider);
  if (config.useSupabaseBackend) {
    return SupabaseWalkRepository(ref.watch(supabaseClientProvider));
  }

  if (config.useFirebaseBackend) {
    return ApiWalksRepository(ref.watch(apiClientProvider));
  }

  return MockWalksRepository();
});

final walksControllerProvider =
    StateNotifierProvider<WalksController, AsyncValue<List<Walk>>>((ref) {
  final config = ref.watch(backendConfigProvider);
  return WalksController(
    repository: ref.watch(walksRepositoryProvider),
    analytics: ref.watch(analyticsServiceProvider),
    loadOnStart: config.useSupabaseBackend || config.useFirebaseBackend,
  );
});

enum WalkJoinStatus {
  joined,
  alreadyJoined,
  left,
  unavailable,
  failed,
}

class WalksController extends StateNotifier<AsyncValue<List<Walk>>> {
  WalksController({
    WalksRepository? repository,
    AnalyticsService? analytics,
    AsyncValue<List<Walk>>? initialState,
    bool loadOnStart = false,
  })  : _analytics = analytics,
        _repository = repository ??
            MockWalksRepository(
              initialWalks: _resolveInitialWalks(initialState),
            ),
        super(initialState ??
            AsyncValue.data(_resolveInitialWalks(initialState))) {
    if (loadOnStart) {
      unawaited(refresh());
    }
  }

  final WalksRepository _repository;
  final AnalyticsService? _analytics;
  WalkFilters _filters = const WalkFilters();

  WalkFilters get filters => _filters;

  static List<Walk> _resolveInitialWalks(
    AsyncValue<List<Walk>>? initialState,
  ) {
    return List<Walk>.unmodifiable(initialState?.asData?.value ?? mockWalks);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();

    try {
      final walks = await _repository.fetchWalks(filters: _filters);
      state = AsyncValue.data(List<Walk>.unmodifiable(walks));
    } catch (error, stackTrace) {
      await _analytics?.trackBackendError(
        operation: 'walks_refresh',
        error: error,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateFilters(WalkFilters filters) async {
    _filters = filters;
    await _analytics?.track(
      AnalyticsEvent.walkFilterChanged,
      params: {
        'status': filters.status.name,
        'has_date': filters.date != null,
        'has_location': filters.normalizedLocationQuery.isNotEmpty,
      },
    );
    await refresh();
  }

  Future<void> clearFilters() {
    return updateFilters(const WalkFilters());
  }

  Future<WalkJoinStatus> joinWalk(String walkId) async {
    final walks = state.asData?.value;
    if (walks == null) {
      return WalkJoinStatus.unavailable;
    }

    Walk? selectedWalk;
    for (final walk in walks) {
      if (walk.id == walkId) {
        selectedWalk = walk;
        break;
      }
    }

    if (selectedWalk == null) {
      return WalkJoinStatus.unavailable;
    }

    if (selectedWalk.isJoined) {
      return WalkJoinStatus.alreadyJoined;
    }

    try {
      final result = await _repository.joinWalk(walkId);
      _applyJoinResult(result);
      if (!result.alreadyJoined && result.isJoined) {
        await _analytics?.track(AnalyticsEvent.walkJoined);
      }
      return result.alreadyJoined
          ? WalkJoinStatus.alreadyJoined
          : WalkJoinStatus.joined;
    } catch (error, stackTrace) {
      await _analytics?.trackBackendError(
        operation: 'walk_join',
        error: error,
      );
      state = AsyncValue.error(error, stackTrace);
      return WalkJoinStatus.failed;
    }
  }

  Future<WalkJoinStatus> leaveWalk(String walkId) async {
    final walks = state.asData?.value;
    if (walks == null) {
      return WalkJoinStatus.unavailable;
    }

    Walk? selectedWalk;
    for (final walk in walks) {
      if (walk.id == walkId) {
        selectedWalk = walk;
        break;
      }
    }
    if (selectedWalk == null || !selectedWalk.isJoined) {
      return WalkJoinStatus.unavailable;
    }

    try {
      final result = await _repository.leaveWalk(walkId);
      _applyJoinResult(result);
      return WalkJoinStatus.left;
    } catch (error, stackTrace) {
      await _analytics?.trackBackendError(
        operation: 'walk_leave',
        error: error,
      );
      state = AsyncValue.error(error, stackTrace);
      return WalkJoinStatus.failed;
    }
  }

  Future<void> createWalk({
    required AppUser organizer,
    required String title,
    required String place,
    required DateTime startsAt,
    required String description,
  }) async {
    final input = _validateCreateWalkInput(
      organizer: organizer,
      title: title,
      place: place,
      startsAt: startsAt,
      description: description,
    );
    final currentWalks = state.asData?.value ?? const <Walk>[];

    late final Walk created;
    try {
      created = await _repository.createWalk(input);
    } catch (error, stackTrace) {
      await _analytics?.trackBackendError(
        operation: 'walk_create',
        error: error,
      );
      Error.throwWithStackTrace(error, stackTrace);
    }

    if (_filters.matches(created)) {
      final updated = [created, ...currentWalks]
        ..sort((left, right) => left.startsAt.compareTo(right.startsAt));
      state = AsyncValue.data(List<Walk>.unmodifiable(updated));
    } else {
      state = AsyncValue.data(currentWalks);
    }
  }

  CreateWalkInput _validateCreateWalkInput({
    required AppUser organizer,
    required String title,
    required String place,
    required DateTime startsAt,
    required String description,
  }) {
    final trimmedTitle = title.trim();
    final trimmedPlace = place.trim();
    final trimmedDescription = description.trim();
    final now = DateTime.now();

    if (trimmedTitle.isEmpty) {
      throw ArgumentError('Укажите название прогулки.');
    }
    if (trimmedTitle.length > 120) {
      throw ArgumentError('Название прогулки должно быть до 120 символов.');
    }
    if (trimmedPlace.isEmpty) {
      throw ArgumentError('Укажите место прогулки.');
    }
    if (trimmedPlace.length > 160) {
      throw ArgumentError('Место должно быть до 160 символов.');
    }
    if (startsAt.isBefore(now.add(const Duration(minutes: 15)))) {
      throw ArgumentError('Выберите время хотя бы на 15 минут вперед.');
    }
    if (startsAt.isAfter(now.add(const Duration(days: 365)))) {
      throw ArgumentError('Прогулку можно запланировать не дальше года.');
    }
    if (trimmedDescription.isEmpty) {
      throw ArgumentError('Добавьте короткое описание прогулки.');
    }
    if (trimmedDescription.length > 500) {
      throw ArgumentError('Описание должно быть до 500 символов.');
    }

    return CreateWalkInput(
      title: trimmedTitle,
      place: trimmedPlace,
      startsAt: startsAt,
      description: trimmedDescription,
      organizerName: organizer.displayName ?? organizer.email,
    );
  }

  void _applyJoinResult(WalkJoinResult result) {
    final walks = state.asData?.value;
    if (walks == null) {
      return;
    }

    final updated = walks.map((walk) {
      if (walk.id != result.walkId) {
        return walk;
      }

      return walk.copyWith(
        isJoined: result.isJoined,
        participantCount: result.participantsCount,
      );
    }).toList(growable: false);

    state = AsyncValue.data(updated);
  }
}
