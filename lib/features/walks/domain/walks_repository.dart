import 'walk.dart';

abstract class WalksRepository {
  Future<List<Walk>> fetchWalks({
    int limit = 20,
    WalkFilters filters = const WalkFilters(),
  });

  Future<Walk> createWalk(CreateWalkInput input);

  Future<WalkJoinResult> joinWalk(String walkId);

  Future<WalkJoinResult> leaveWalk(String walkId);
}

enum WalkStatusFilter {
  all,
  upcoming,
  completed,
}

class WalkFilters {
  const WalkFilters({
    this.date,
    this.locationQuery = '',
    this.status = WalkStatusFilter.upcoming,
  });

  final DateTime? date;
  final String locationQuery;
  final WalkStatusFilter status;

  String get normalizedLocationQuery => locationQuery.trim().toLowerCase();

  bool get hasActiveFilters {
    return date != null ||
        normalizedLocationQuery.isNotEmpty ||
        status != WalkStatusFilter.upcoming;
  }

  WalkFilters copyWith({
    DateTime? date,
    bool clearDate = false,
    String? locationQuery,
    WalkStatusFilter? status,
  }) {
    return WalkFilters(
      date: clearDate ? null : date ?? this.date,
      locationQuery: locationQuery ?? this.locationQuery,
      status: status ?? this.status,
    );
  }

  bool matches(Walk walk) {
    if (!_matchesStatus(walk)) {
      return false;
    }

    final selectedDate = date;
    if (selectedDate != null && !_isSameDay(walk.startsAt, selectedDate)) {
      return false;
    }

    final location = normalizedLocationQuery;
    if (location.isNotEmpty &&
        !walk.place.toLowerCase().contains(location) &&
        !walk.title.toLowerCase().contains(location)) {
      return false;
    }

    return true;
  }

  bool _matchesStatus(Walk walk) {
    final now = DateTime.now();
    return switch (status) {
      WalkStatusFilter.all => true,
      WalkStatusFilter.upcoming => !walk.startsAt.isBefore(now),
      WalkStatusFilter.completed => walk.startsAt.isBefore(now),
    };
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
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
