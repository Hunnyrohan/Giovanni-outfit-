import '../../domain/entities/wardrobe_item_entity.dart';

class WardrobeItemModel extends WardrobeItemEntity {
  const WardrobeItemModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.price,
    required super.rating,
    required super.imageUrl,
    required super.category,
    required super.colors,
    required super.sizes,
    super.isFavorite,
    super.isSavedOutfit,
    super.isMarketplaceItem,
  });

  factory WardrobeItemModel.fromJson(Map<String, dynamic> json) {
    return WardrobeItemModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      colors: List<String>.from(json['colors'] as List),
      sizes: List<String>.from(json['sizes'] as List),
      isFavorite: json['isFavorite'] as bool? ?? false,
      isSavedOutfit: json['isSavedOutfit'] as bool? ?? false,
      isMarketplaceItem: json['isMarketplaceItem'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'price': price,
      'rating': rating,
      'imageUrl': imageUrl,
      'category': category,
      'colors': colors,
      'sizes': sizes,
      'isFavorite': isFavorite,
      'isSavedOutfit': isSavedOutfit,
      'isMarketplaceItem': isMarketplaceItem,
    };
  }

  factory WardrobeItemModel.fromEntity(WardrobeItemEntity entity) {
    return WardrobeItemModel(
      id: entity.id,
      title: entity.title,
      subtitle: entity.subtitle,
      price: entity.price,
      rating: entity.rating,
      imageUrl: entity.imageUrl,
      category: entity.category,
      colors: entity.colors,
      sizes: entity.sizes,
      isFavorite: entity.isFavorite,
      isSavedOutfit: entity.isSavedOutfit,
      isMarketplaceItem: entity.isMarketplaceItem,
    );
  }
}
