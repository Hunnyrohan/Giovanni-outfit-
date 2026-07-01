import '../../domain/entities/recommended_outfit_entity.dart';

class RecommendedOutfitModel extends RecommendedOutfitEntity {
  const RecommendedOutfitModel({
    required super.id,
    required super.title,
    required super.category,
    required super.imageUrl,
    required super.isFavorite,
    required super.occasion,
    required super.description,
  });

  factory RecommendedOutfitModel.fromJson(Map<String, dynamic> json) {
    return RecommendedOutfitModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
      isFavorite: json['isFavorite'] as bool,
      occasion: json['occasion'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
      'occasion': occasion,
      'description': description,
    };
  }
}
