import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../../core/config/backend_config.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/network/api_client.dart';
import '../../../core/supabase/supabase_client_provider.dart';
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

  static List<Walk> _resolveInitialWalks(
    AsyncValue<List<Walk>>? initialState,
  ) {
    return List<Walk>.unmodifiable(initialState?.asData?.value ?? mockWalks);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();

    try {
      final walks = await _repository.fetchWalks();
      state = AsyncValue.data(List<Walk>.unmodifiable(walks));
    } catch (error, stackTrace) {
      await _analytics?.trackBackendError(
        operation: 'walks_refresh',
        error: error,
      );
      state = AsyncValue.error(error, stackTrace);
    }
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
