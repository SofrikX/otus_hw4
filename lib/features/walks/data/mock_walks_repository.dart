import '../../../core/data/mock_data.dart';
import '../domain/walk.dart';
import '../domain/walks_repository.dart';

class MockWalksRepository implements WalksRepository {
  MockWalksRepository({List<Walk>? initialWalks})
      : _walks = List<Walk>.unmodifiable(initialWalks ?? mockWalks);

  List<Walk> _walks;

  @override
  Future<List<Walk>> fetchWalks({int limit = 20}) async {
    return _walks.take(limit).toList(growable: false);
  }

  @override
  Future<WalkJoinResult> joinWalk(String walkId) async {
    Walk? updatedWalk;
    _walks = _walks.map((walk) {
      if (walk.id != walkId || walk.isJoined) {
        return walk;
      }

      updatedWalk = walk.copyWith(
        isJoined: true,
        participantCount: walk.participantCount + 1,
      );

      return updatedWalk!;
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
    );
  }
}
