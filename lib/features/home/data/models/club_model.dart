import '../../domain/entities/club.dart';

class ClubModel extends Club {
  const ClubModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrl,
    required super.category,
    required super.memberCount,
    required super.rating,
    required super.tags,
    required super.isFollowed,
  });

  factory ClubModel.fromJson(Map<String, dynamic> json) {
    return ClubModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      memberCount: json['memberCount'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      isFollowed: json['isFollowed'] ?? false,
    );
  }

  factory ClubModel.fromEntity(Club entity) {
    return ClubModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      imageUrl: entity.imageUrl,
      category: entity.category,
      memberCount: entity.memberCount,
      rating: entity.rating,
      tags: entity.tags,
      isFollowed: entity.isFollowed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'memberCount': memberCount,
      'rating': rating,
      'tags': tags,
      'isFollowed': isFollowed,
    };
  }
}
