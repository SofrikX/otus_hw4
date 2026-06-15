class Walk {
  const Walk({
    required this.id,
    required this.title,
    required this.place,
    required this.startsAt,
    required this.description,
    required this.organizerName,
    required this.participantCount,
    required this.isJoined,
  });

  final String id;
  final String title;
  final String place;
  final DateTime startsAt;
  final String description;
  final String organizerName;
  final int participantCount;
  final bool isJoined;

  Walk copyWith({
    String? id,
    String? title,
    String? place,
    DateTime? startsAt,
    String? description,
    String? organizerName,
    int? participantCount,
    bool? isJoined,
  }) {
    return Walk(
      id: id ?? this.id,
      title: title ?? this.title,
      place: place ?? this.place,
      startsAt: startsAt ?? this.startsAt,
      description: description ?? this.description,
      organizerName: organizerName ?? this.organizerName,
      participantCount: participantCount ?? this.participantCount,
      isJoined: isJoined ?? this.isJoined,
    );
  }

  factory Walk.fromJson(Map<String, dynamic> json) {
    return Walk(
      id: json['id'] as String,
      title: json['title'] as String,
      place: json['place'] as String,
      startsAt: DateTime.parse(json['startsAt'] as String),
      description: json['description'] as String,
      organizerName: json['organizerName'] as String,
      participantCount: json['participantCount'] as int,
      isJoined: json['isJoined'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'place': place,
      'startsAt': startsAt.toIso8601String(),
      'description': description,
      'organizerName': organizerName,
      'participantCount': participantCount,
      'isJoined': isJoined,
    };
  }
}
