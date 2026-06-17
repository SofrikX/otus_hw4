import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/backend_config.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/network/api_client.dart';
import '../data/api_walks_repository.dart';
import '../data/mock_walks_repository.dart';
import '../domain/walk.dart';
import '../domain/walks_repository.dart';

final walksRepositoryProvider = Provider<WalksRepository>((ref) {
  final config = ref.watch(backendConfigProvider);
  if (config.useFirebaseBackend) {
    return ApiWalksRepository(ref.watch(apiClientProvider));
  }

  return MockWalksRepository();
});

final walksControllerProvider =
    StateNotifierProvider<WalksController, AsyncValue<List<Walk>>>((ref) {
  final useFirebaseBackend =
      ref.watch(backendConfigProvider).useFirebaseBackend;
  return WalksController(
    repository: ref.watch(walksRepositoryProvider),
    loadOnStart: useFirebaseBackend,
  );
});

class WalksController extends StateNotifier<AsyncValue<List<Walk>>> {
  WalksController({
    WalksRepository? repository,
    AsyncValue<List<Walk>>? initialState,
    bool loadOnStart = false,
  })  : _repository = repository ??
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

  static List<Walk> _resolveInitialWalks(
    AsyncValue<List<Walk>>? initialState,
  ) {
    return List<Walk>.unmodifiable(initialState?.asData?.value ?? mockWalks);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final walks = await _repository.fetchWalks();
      return List<Walk>.unmodifiable(walks);
    });
  }

  Future<bool> joinWalk(String walkId) async {
    final walks = state.asData?.value;
    if (walks == null) {
      return false;
    }

    Walk? selectedWalk;
    for (final walk in walks) {
      if (walk.id == walkId) {
        selectedWalk = walk;
        break;
      }
    }

    if (selectedWalk == null || selectedWalk.isJoined) {
      return false;
    }

    try {
      final result = await _repository.joinWalk(walkId);
      _applyJoinResult(result);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
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
