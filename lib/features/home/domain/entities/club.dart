import 'package:equatable/equatable.dart';

class Club extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final int memberCount;
  final double rating;
  final List<String> tags;
  final bool isFollowed;

  const Club({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.memberCount,
    required this.rating,
    required this.tags,
    required this.isFollowed,
  });

  Club copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? category,
    int? memberCount,
    double? rating,
    List<String>? tags,
    bool? isFollowed,
  }) {
    return Club(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      memberCount: memberCount ?? this.memberCount,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        category,
        memberCount,
        rating,
        tags,
        isFollowed,
      ];
}
