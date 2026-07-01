class WardrobeItemEntity {
  final String id;
  final String title;
  final String subtitle;
  final double price;
  final double rating;
  final String imageUrl;
  final String category;
  final List<String> colors;
  final List<String> sizes;
  final bool isFavorite;
  final bool isSavedOutfit;
  final bool isMarketplaceItem;

  const WardrobeItemEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.category,
    required this.colors,
    required this.sizes,
    this.isFavorite = false,
    this.isSavedOutfit = false,
    this.isMarketplaceItem = false,
  });

  WardrobeItemEntity copyWith({
    String? id,
    String? title,
    String? subtitle,
    double? price,
    double? rating,
    String? imageUrl,
    String? category,
    List<String>? colors,
    List<String>? sizes,
    bool? isFavorite,
    bool? isSavedOutfit,
    bool? isMarketplaceItem,
  }) {
    return WardrobeItemEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
      isFavorite: isFavorite ?? this.isFavorite,
      isSavedOutfit: isSavedOutfit ?? this.isSavedOutfit,
      isMarketplaceItem: isMarketplaceItem ?? this.isMarketplaceItem,
    );
  }
}
