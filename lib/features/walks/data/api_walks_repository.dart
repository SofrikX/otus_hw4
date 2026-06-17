import '../../../core/network/api_client.dart';
import '../domain/walk.dart';
import '../domain/walks_repository.dart';

class ApiWalksRepository implements WalksRepository {
  const ApiWalksRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Walk>> fetchWalks({int limit = 20}) async {
    final walks = await _apiClient.getWalks(limit: limit);
    return walks.map(_mapWalk).toList(growable: false);
  }

  @override
  Future<Walk> createWalk(CreateWalkInput input) async {
    throw UnsupportedError(
      'Creating walks is not supported by the legacy API repository.',
    );
  }

  @override
  Future<WalkJoinResult> joinWalk(String walkId) async {
    final result = await _apiClient.joinWalk(walkId);
    return WalkJoinResult.fromJson(result);
  }

  @override
  Future<WalkJoinResult> leaveWalk(String walkId) async {
    throw UnsupportedError(
      'Leaving walks is not supported by the legacy API repository.',
    );
  }

  Walk _mapWalk(Map<String, dynamic> json) {
    return Walk(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Прогулка',
      place: json['place'] as String? ?? 'Место уточняется',
      startsAt: DateTime.parse(
        json['startsAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      description: json['description'] as String? ?? '',
      organizerName: json['organizerName'] as String? ?? 'Организатор',
      participantCount: json['participantsCount'] as int? ??
          json['participantCount'] as int? ??
          0,
      isJoined: json['isJoined'] as bool? ?? false,
    );
  }
}
