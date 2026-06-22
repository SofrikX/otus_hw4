class Pet {
  const Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.animalType,
    required this.breed,
    required this.age,
    required this.description,
    required this.photoEmoji,
    required this.ownerName,
    this.photoUrl,
  });

  final String id;
  final String ownerId;
  final String name;
  final String animalType;
  final String breed;
  final int age;
  final String description;
  final String photoEmoji;
  final String ownerName;
  final String? photoUrl;

  Pet copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? animalType,
    String? breed,
    int? age,
    String? description,
    String? photoEmoji,
    String? ownerName,
    String? photoUrl,
  }) {
    return Pet(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      animalType: animalType ?? this.animalType,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      description: description ?? this.description,
      photoEmoji: photoEmoji ?? this.photoEmoji,
      ownerName: ownerName ?? this.ownerName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      animalType: json['animalType'] as String,
      breed: json['breed'] as String,
      age: json['age'] as int,
      description: json['description'] as String,
      photoEmoji: json['photoEmoji'] as String,
      ownerName: json['ownerName'] as String,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'animalType': animalType,
      'breed': breed,
      'age': age,
      'description': description,
      'photoEmoji': photoEmoji,
      'ownerName': ownerName,
      'photoUrl': photoUrl,
    };
  }
}
