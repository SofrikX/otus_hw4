import 'walk.dart';

abstract class WalksRepository {
  Future<List<Walk>> fetchWalks({int limit = 20});

  Future<Walk> createWalk(CreateWalkInput input);

  Future<WalkJoinResult> joinWalk(String walkId);

  Future<WalkJoinResult> leaveWalk(String walkId);
}

class CreateWalkInput {
  const CreateWalkInput({
    required this.title,
    required this.place,
    required this.startsAt,
    required this.description,
    this.organizerName,
  });

  final String title;
  final String place;
  final DateTime startsAt;
  final String description;
  final String? organizerName;
}

class WalkJoinResult {
  const WalkJoinResult({
    required this.walkId,
    required this.isJoined,
    required this.participantsCount,
    this.alreadyJoined = false,
  });

  final String walkId;
  final bool isJoined;
  final int participantsCount;
  final bool alreadyJoined;

  factory WalkJoinResult.fromJson(Map<String, dynamic> json) {
    return WalkJoinResult(
      walkId: json['walkId'] as String,
      isJoined: json['isJoined'] as bool,
      participantsCount: json['participantsCount'] as int,
      alreadyJoined: json['alreadyJoined'] as bool? ?? false,
    );
  }
}
