import '../../../../core/constants/api_constants.dart';
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

  /// Maps the real backend's wardrobe item shape (`id, name, description,
  /// imageUrl, category, subCategory, primaryColor, colors, brand, size,
  /// material, season, occasion, tags, isFavorite, isArchived, ...`) onto
  /// this UI-facing entity. The backend has no price/rating/subtitle concept
  /// (those belong to a marketplace-style mock, not a real wardrobe item),
  /// so they're given sensible defaults rather than invented.
  factory WardrobeItemModel.fromBackendJson(Map<String, dynamic> json) {
    final size = json['size'] as String?;
    return WardrobeItemModel(
      id: json['id'] as String,
      title: json['name'] as String,
      subtitle: (json['brand'] as String?) ?? (json['category'] as String? ?? ''),
      price: 0.0,
      rating: 0.0,
      imageUrl: ApiConstants.resolveMediaUrl(json['imageUrl'] as String?) ?? '',
      // The UI's category chips use display names ('T-shirts', 'Jacket'...)
      // that live in the backend's free-form subCategory field; the enum
      // category (TOP, OUTERWEAR...) is only the fallback so items without
      // a subCategory still land somewhere visible.
      category: (json['subCategory'] as String?) ?? (json['category'] as String? ?? 'Other'),
      colors: List<String>.from(json['colors'] as List? ?? const []),
      sizes: size == null ? const [] : [size],
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
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
