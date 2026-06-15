class PetPost {
  const PetPost({
    required this.id,
    required this.petId,
    required this.petName,
    required this.authorName,
    required this.petEmoji,
    required this.imageEmoji,
    required this.text,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
  });

  final String id;
  final String petId;
  final String petName;
  final String authorName;
  final String petEmoji;
  final String imageEmoji;
  final String text;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;

  PetPost copyWith({
    String? id,
    String? petId,
    String? petName,
    String? authorName,
    String? petEmoji,
    String? imageEmoji,
    String? text,
    DateTime? createdAt,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
  }) {
    return PetPost(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      authorName: authorName ?? this.authorName,
      petEmoji: petEmoji ?? this.petEmoji,
      imageEmoji: imageEmoji ?? this.imageEmoji,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  factory PetPost.fromJson(Map<String, dynamic> json) {
    return PetPost(
      id: json['id'] as String,
      petId: json['petId'] as String,
      petName: json['petName'] as String,
      authorName: json['authorName'] as String,
      petEmoji: json['petEmoji'] as String,
      imageEmoji: json['imageEmoji'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likesCount: json['likesCount'] as int,
      commentsCount: json['commentsCount'] as int,
      isLiked: json['isLiked'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'petName': petName,
      'authorName': authorName,
      'petEmoji': petEmoji,
      'imageEmoji': imageEmoji,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'isLiked': isLiked,
    };
  }
}
