import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/mock_data.dart';
import '../domain/walk.dart';

final walksControllerProvider =
    StateNotifierProvider<WalksController, AsyncValue<List<Walk>>>((ref) {
  return WalksController();
});

class WalksController extends StateNotifier<AsyncValue<List<Walk>>> {
  WalksController({AsyncValue<List<Walk>>? initialState})
      : super(initialState ?? AsyncValue.data(List<Walk>.unmodifiable(mockWalks)));

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

    state = AsyncValue.data(List<Walk>.unmodifiable(mockWalks));
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
  }
}
