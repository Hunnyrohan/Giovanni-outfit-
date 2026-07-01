class RecommendedOutfitEntity {
  const RecommendedOutfitEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.isFavorite,
    required this.occasion,
    required this.description,
  });

  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final bool isFavorite;
  final String occasion;
  final String description;

  RecommendedOutfitEntity copyWith({
    String? id,
    String? title,
    String? category,
    String? imageUrl,
    bool? isFavorite,
    String? occasion,
    String? description,
  }) {
    return RecommendedOutfitEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      occasion: occasion ?? this.occasion,
      description: description ?? this.description,
    );
  }
}
