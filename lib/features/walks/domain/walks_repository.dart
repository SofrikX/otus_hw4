import 'walk.dart';

abstract class WalksRepository {
  Future<List<Walk>> fetchWalks({int limit = 20});

  Future<WalkJoinResult> joinWalk(String walkId);
}

class WalkJoinResult {
  const WalkJoinResult({
    required this.walkId,
    required this.isJoined,
    required this.participantsCount,
  });

  final String walkId;
  final bool isJoined;
  final int participantsCount;

  factory WalkJoinResult.fromJson(Map<String, dynamic> json) {
    return WalkJoinResult(
      walkId: json['walkId'] as String,
      isJoined: json['isJoined'] as bool,
      participantsCount: json['participantsCount'] as int,
    );
  }
}
