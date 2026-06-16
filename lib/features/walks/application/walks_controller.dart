import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<void> refresh({bool shouldFail = false}) async {
    state = const AsyncValue.loading();
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (shouldFail) {
      state = AsyncValue.error(
        Exception('Не удалось загрузить прогулки рядом.'),
        StackTrace.current,
      );
      return;
    }

    state = await AsyncValue.guard(() async {
      final walks = await _repository.fetchWalks();
      return List<Walk>.unmodifiable(walks);
    });
  }

  void joinWalk(String walkId) {
    final walks = state.asData?.value;
    if (walks == null) {
      return;
    }

    final updated = walks.map((walk) {
      if (walk.id != walkId || walk.isJoined) {
        return walk;
      }

      return walk.copyWith(
        isJoined: true,
        participantCount: walk.participantCount + 1,
      );
    }).toList(growable: false);

    state = AsyncValue.data(updated);
    unawaited(_syncJoin(walkId));
  }

  Future<void> _syncJoin(String walkId) async {
    try {
      final result = await _repository.joinWalk(walkId);
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
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
