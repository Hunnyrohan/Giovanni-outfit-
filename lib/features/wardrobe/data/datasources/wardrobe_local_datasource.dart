import '../models/wardrobe_item_model.dart';

class WardrobeLocalDatasource {
  final List<WardrobeItemModel> _items = [
    // ----------------------------------------------------
    // MY WARDROBE ITEMS
    // ----------------------------------------------------
    const WardrobeItemModel(
      id: 'w1',
      title: 'Black formal shirt',
      subtitle: 'Tailored slim-fit shirt',
      price: 25.00,
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1603252109303-2751441dd157?w=600&auto=format&fit=crop&q=85',
      category: 'T-shirts',
      colors: ['#000000', '#1C1C1E'],
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      isFavorite: true,
    ),
    const WardrobeItemModel(
      id: 'w2',
      title: 'White T-shirt',
      subtitle: 'Classic everyday fit',
      price: 22.00,
      rating: 4.6,
      imageUrl:
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600&auto=format&fit=crop&q=85',
      category: 'T-shirts',
      colors: ['#FFFFFF', '#E5E5EA'],
      sizes: ['S', 'M', 'L', 'XL'],
      isFavorite: false,
    ),
    const WardrobeItemModel(
      id: 'w3',
      title: 'Blue shirt',
      subtitle: 'Patterned button shirt',
      price: 45.00,
      rating: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600&auto=format&fit=crop&q=85',
      category: 'T-shirts',
      colors: ['#6F8FAF', '#FFFFFF'],
      sizes: ['S', 'M', 'L'],
      isFavorite: false,
    ),
    const WardrobeItemModel(
      id: 'w4',
      title: 'White graphic tee',
      subtitle: 'Printed casual t-shirt',
      price: 18.00,
      rating: 4.5,
      imageUrl:
          'https://images.unsplash.com/photo-1554568218-0f1715e72254?w=600&auto=format&fit=crop&q=85',
      category: 'Crop top',
      colors: ['#FFB6C1', '#FFC0CB'],
      sizes: ['XS', 'S', 'M'],
      isFavorite: true,
    ),
    const WardrobeItemModel(
      id: 'w5',
      title: 'Black leather jacket',
      subtitle: 'Glossy moto jacket',
      price: 120.00,
      rating: 4.9,
      imageUrl:
          'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600&auto=format&fit=crop&q=85',
      category: 'Jacket',
      colors: ['#8B4513', '#D2691E'],
      sizes: ['M', 'L', 'XL'],
      isFavorite: false,
    ),
    const WardrobeItemModel(
      id: 'w6',
      title: 'Gray hoodie',
      subtitle: 'Soft fleece pullover',
      price: 65.00,
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=600&auto=format&fit=crop&q=85',
      category: 'Jacket',
      colors: ['#FFFFFF', '#D1D1D6'],
      sizes: ['S', 'M', 'L', 'XL'],
      isFavorite: false,
    ),

    // ----------------------------------------------------
    // SAVED OUTFIT ITEMS
    // ----------------------------------------------------
    const WardrobeItemModel(
      id: 's1',
      title: 'White printed sweatshirt',
      subtitle: 'Vintage aesthetic print',
      price: 55.00,
      rating: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600&auto=format&fit=crop&q=80',
      category: 'Jacket',
      colors: ['#FFFFFF', '#EAEAEA'],
      sizes: ['M', 'L', 'XL'],
      isFavorite: true,
      isSavedOutfit: true,
    ),
    const WardrobeItemModel(
      id: 's2',
      title: 'Blue shirt',
      subtitle: 'Patterned button shirt',
      price: 48.00,
      rating: 4.6,
      imageUrl:
          'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600&auto=format&fit=crop&q=80',
      category: 'T-shirts',
      colors: ['#6F8FAF', '#FFFFFF'],
      sizes: ['S', 'M', 'L'],
      isFavorite: false,
      isSavedOutfit: true,
    ),
    const WardrobeItemModel(
      id: 's3',
      title: 'Black formal shirt',
      subtitle: 'Tailored slim-fit stretch oxford',
      price: 60.00,
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1603252109303-2751441dd157?w=600&auto=format&fit=crop&q=80',
      category: 'T-shirts',
      colors: ['#000000', '#1C1C1E'],
      sizes: ['S', 'M', 'L', 'XL'],
      isFavorite: true,
      isSavedOutfit: true,
    ),
    const WardrobeItemModel(
      id: 's4',
      title: 'Two tone long-sleeve shirt',
      subtitle: 'Colorblocked heavyweight knit',
      price: 21.00,
      rating: 4.5,
      imageUrl:
          'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=600&auto=format&fit=crop&q=80',
      category: 'T-shirts',
      colors: ['#EAE5D9', '#0A122C', '#3A3A3C'],
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      isFavorite: false,
      isSavedOutfit: true,
    ),
    const WardrobeItemModel(
      id: 's5',
      title: 'White graphic hoodie',
      subtitle: 'Streetwear graphic prints',
      price: 70.00,
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=600&auto=format&fit=crop&q=80',
      category: 'Jacket',
      colors: ['#FFFFFF', '#000000'],
      sizes: ['M', 'L', 'XL'],
      isFavorite: false,
      isSavedOutfit: true,
    ),
    const WardrobeItemModel(
      id: 's6',
      title: 'Black outfit set',
      subtitle: 'Cohesive fashion matching top & bottom',
      price: 110.00,
      rating: 4.9,
      imageUrl:
          'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600&auto=format&fit=crop&q=80',
      category: 'Crop top',
      colors: ['#000000'],
      sizes: ['XS', 'S', 'M', 'L'],
      isFavorite: true,
      isSavedOutfit: true,
    ),

    // ----------------------------------------------------
    // MARKETPLACE ITEMS (ADD COLLECTION DISCOVERY)
    // ----------------------------------------------------
    const WardrobeItemModel(
      id: 'm1',
      title: 'Green shirt',
      subtitle: 'Casual structured cotton overshirt',
      price: 50.00,
      rating: 4.5,
      imageUrl:
          'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600&auto=format&fit=crop&q=80',
      category: 'T-shirts',
      colors: ['#2E8B57', '#006400'],
      sizes: ['S', 'M', 'L', 'XL'],
      isFavorite: false,
      isMarketplaceItem: true,
    ),
    const WardrobeItemModel(
      id: 'm2',
      title: 'White shirt',
      subtitle: 'Crisp casual linen button-down',
      price: 40.00,
      rating: 4.6,
      imageUrl:
          'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?w=600&auto=format&fit=crop&q=80',
      category: 'T-shirts',
      colors: ['#FFFFFF'],
      sizes: ['S', 'M', 'L'],
      isFavorite: false,
      isMarketplaceItem: true,
    ),
    const WardrobeItemModel(
      id: 'm3',
      title: 'White over shirt',
      subtitle: 'Heavy utility twill layer',
      price: 97.00,
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1578587018452-892bacefd3f2?w=600&auto=format&fit=crop&q=80',
      category: 'Jacket',
      colors: ['#FFFFFF', '#D1D1D6'],
      sizes: ['M', 'L', 'XL'],
      isFavorite: false,
      isMarketplaceItem: true,
    ),
    const WardrobeItemModel(
      id: 'm4',
      title: 'Navy T-shirt',
      subtitle: 'Essential breathable tee',
      price: 20.00,
      rating: 4.3,
      imageUrl:
          'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=600&auto=format&fit=crop&q=80',
      category: 'T-shirts',
      colors: ['#0A122C', '#3A3A3C', '#E5E5EA'],
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      isFavorite: false,
      isMarketplaceItem: true,
    ),
    const WardrobeItemModel(
      id: 'm5',
      title: 'Orange hoodie',
      subtitle: 'Premium fleece hoodie',
      price: 80.00,
      rating: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1509967419530-da38b4704bc6?w=600&auto=format&fit=crop&q=80',
      category: 'Jacket',
      colors: ['#FF4500', '#3A3A3C'],
      sizes: ['M', 'L', 'XL'],
      isFavorite: false,
      isMarketplaceItem: true,
    ),
    const WardrobeItemModel(
      id: 'm6',
      title: 'Black formal shirt',
      subtitle: 'Relaxed fit black shirt',
      price: 67.00,
      rating: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1603252109303-2751441dd157?w=600&auto=format&fit=crop&q=80',
      category: 'T-shirts',
      colors: ['#000000', '#2C2C2E'],
      sizes: ['S', 'M', 'L'],
      isFavorite: false,
      isMarketplaceItem: true,
    ),
  ];

  Future<List<WardrobeItemModel>> getWardrobeItems() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _items
        .where((e) => !e.isSavedOutfit && !e.isMarketplaceItem)
        .toList();
  }

  Future<List<WardrobeItemModel>> getSavedOutfits() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _items.where((e) => e.isSavedOutfit).toList();
  }

  Future<List<WardrobeItemModel>> getMarketplaceItems() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _items.where((e) => e.isMarketplaceItem).toList();
  }

  Future<void> toggleFavorite(String id) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final item = _items[idx];
      _items[idx] = WardrobeItemModel(
        id: item.id,
        title: item.title,
        subtitle: item.subtitle,
        price: item.price,
        rating: item.rating,
        imageUrl: item.imageUrl,
        category: item.category,
        colors: item.colors,
        sizes: item.sizes,
        isFavorite: !item.isFavorite,
        isSavedOutfit: item.isSavedOutfit,
        isMarketplaceItem: item.isMarketplaceItem,
      );
    }
  }

  Future<void> addToWardrobe(WardrobeItemModel item) async {
    // Add to local list, make sure it is not marked as marketplace item, so it appears in wardrobe
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _items[index] = WardrobeItemModel(
        id: item.id,
        title: item.title,
        subtitle: item.subtitle,
        price: item.price,
        rating: item.rating,
        imageUrl: item.imageUrl,
        category: item.category,
        colors: item.colors,
        sizes: item.sizes,
        isFavorite: item.isFavorite,
        isSavedOutfit: false, // Make sure it is in wardrobe
        isMarketplaceItem: false, // Not purely marketplace anymore
      );
    } else {
      _items.add(item);
    }
  }
}
