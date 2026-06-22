import '../../../core/data/mock_data.dart';
import '../domain/walk.dart';
import '../domain/walks_repository.dart';

class MockWalksRepository implements WalksRepository {
  MockWalksRepository({List<Walk>? initialWalks})
      : _walks = List<Walk>.unmodifiable(initialWalks ?? mockWalks);

  List<Walk> _walks;

  @override
  Future<List<Walk>> fetchWalks({
    int limit = 20,
    WalkFilters filters = const WalkFilters(),
  }) async {
    return _walks.where(filters.matches).take(limit).toList(growable: false);
  }

  @override
  Future<Walk> createWalk(CreateWalkInput input) async {
    final walk = Walk(
      id: 'walk-${_walks.length + 1}',
      title: input.title,
      place: input.place,
      startsAt: input.startsAt,
      description: input.description,
      organizerName: input.organizerName ?? 'Вы',
      participantCount: 0,
      isJoined: false,
    );

    _walks = [walk, ..._walks];
    return walk;
  }

  @override
  Future<WalkJoinResult> joinWalk(String walkId) async {
    Walk? updatedWalk;
    var alreadyJoined = false;
    _walks = _walks.map((walk) {
      if (walk.id != walkId) {
        return walk;
      }

      if (walk.isJoined) {
        alreadyJoined = true;
        updatedWalk = walk;
        return walk;
      }

      final joinedWalk = walk.copyWith(
        isJoined: true,
        participantCount: walk.participantCount + 1,
      );
      updatedWalk = joinedWalk;

      return joinedWalk;
    }).toList(growable: false);

    Walk? walk = updatedWalk;
    for (final candidate in _walks) {
      if (candidate.id == walkId) {
        walk = candidate;
        break;
      }
    }

    if (walk == null) {
      throw ArgumentError('Walk not found: $walkId');
    }

    return WalkJoinResult(
      walkId: walk.id,
      isJoined: walk.isJoined,
      participantsCount: walk.participantCount,
      alreadyJoined: alreadyJoined,
    );
  }

  @override
  Future<WalkJoinResult> leaveWalk(String walkId) async {
    Walk? updatedWalk;
    _walks = _walks.map((walk) {
      if (walk.id != walkId) {
        return walk;
      }

      final leftWalk = walk.copyWith(
        isJoined: false,
        participantCount: walk.isJoined && walk.participantCount > 0
            ? walk.participantCount - 1
            : walk.participantCount,
      );
      updatedWalk = leftWalk;

      return leftWalk;
    }).toList(growable: false);

    final walk = updatedWalk;
    if (walk == null) {
      throw ArgumentError('Walk not found: $walkId');
    }

    return WalkJoinResult(
      walkId: walk.id,
      isJoined: walk.isJoined,
      participantsCount: walk.participantCount,
    );
  }
}
