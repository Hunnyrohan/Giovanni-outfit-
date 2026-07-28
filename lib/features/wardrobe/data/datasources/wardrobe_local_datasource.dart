import '../models/wardrobe_item_model.dart';

class WardrobeLocalDatasource {
  final List<WardrobeItemModel> _items = [
    // ----------------------------------------------------
    // MY WARDROBE ITEMS
    // ----------------------------------------------------
    // -- T-shirts --
    const WardrobeItemModel(
      id: 'w1',
      title: 'White formal shirt',
      subtitle: 'Tailored slim-fit shirt',
      price: 2500.00,
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1603252109303-2751441dd157?w=600&auto=format&fit=crop&q=85',
      category: 'T-shirts',
      colors: ['#FFFFFF', '#F2F2F2'],
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      isFavorite: true,
    ),
    const WardrobeItemModel(
      id: 'w2',
      title: 'White T-shirt',
      subtitle: 'Classic everyday fit',
      price: 2200.00,
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
      title: 'Blue chambray shirt',
      subtitle: 'Dotted button-up shirt',
      price: 4500.00,
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
      price: 1800.00,
      rating: 4.5,
      imageUrl:
          'https://images.unsplash.com/photo-1554568218-0f1715e72254?w=600&auto=format&fit=crop&q=85',
      category: 'T-shirts',
      colors: ['#FFFFFF', '#000000'],
      sizes: ['XS', 'S', 'M'],
      isFavorite: true,
    ),
    const WardrobeItemModel(
      id: 'w9',
      title: 'Beige graphic tee',
      subtitle: 'Printed streetwear t-shirt',
      price: 2400.00,
      rating: 4.6,
      imageUrl:
          'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=600&auto=format&fit=crop&q=85',
      category: 'T-shirts',
      colors: ['#E8DCC8', '#1A3E8C'],
      sizes: ['S', 'M', 'L', 'XL'],
      isFavorite: false,
    ),
    const WardrobeItemModel(
      id: 'w10',
      title: 'Black skeleton graphic tee',
      subtitle: 'Bold printed cotton tee',
      price: 2000.00,
      rating: 4.4,
      imageUrl:
          'https://images.unsplash.com/photo-1503341504253-dff4815485f1?w=600&auto=format&fit=crop&q=85',
      category: 'T-shirts',
      colors: ['#000000', '#FFFFFF'],
      sizes: ['S', 'M', 'L', 'XL'],
      isFavorite: false,
    ),
    const WardrobeItemModel(
      id: 'w11',
      title: 'Lavender graphic tee',
      subtitle: 'Relaxed-fit printed tee',
      price: 1900.00,
      rating: 4.5,
      imageUrl:
          'https://images.unsplash.com/photo-1622470953794-aa9c70b0fb9d?w=600&auto=format&fit=crop&q=85',
      category: 'T-shirts',
      colors: ['#D8BFD8', '#000000'],
      sizes: ['S', 'M', 'L'],
      isFavorite: true,
    ),

    // -- Crop top --
    const WardrobeItemModel(
      id: 'w12',
      title: 'Sequined crop top',
      subtitle: 'Sparkly party crop top',
      price: 5500.00,
      rating: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1550614000-4895a10e1bfd?w=600&auto=format&fit=crop&q=85',
      category: 'Crop top',
      colors: ['#8B0000', '#FFD700'],
      sizes: ['XS', 'S', 'M'],
      isFavorite: true,
    ),
    const WardrobeItemModel(
      id: 'w13',
      title: 'Black cropped tee',
      subtitle: 'Casual tucked-hem crop tee',
      price: 2100.00,
      rating: 4.3,
      imageUrl:
          'https://images.unsplash.com/photo-1583744946564-b52ac1c389c8?w=600&auto=format&fit=crop&q=85',
      category: 'Crop top',
      colors: ['#000000', '#FFFFFF'],
      sizes: ['XS', 'S', 'M', 'L'],
      isFavorite: false,
    ),

    // -- Jacket --
    const WardrobeItemModel(
      id: 'w5',
      title: 'Black leather jacket',
      subtitle: 'Glossy moto jacket',
      price: 12000.00,
      rating: 4.9,
      imageUrl:
          'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600&auto=format&fit=crop&q=85',
      category: 'Jacket',
      colors: ['#000000', '#1C1C1E'],
      sizes: ['M', 'L', 'XL'],
      isFavorite: false,
    ),
    const WardrobeItemModel(
      id: 'w6',
      title: 'Gray hoodie',
      subtitle: 'Soft fleece pullover',
      price: 6500.00,
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=600&auto=format&fit=crop&q=85',
      category: 'Jacket',
      colors: ['#8E8E93', '#AEAEB2'],
      sizes: ['S', 'M', 'L', 'XL'],
      isFavorite: false,
    ),
    const WardrobeItemModel(
      id: 'w14',
      title: 'Rust bomber jacket',
      subtitle: 'Lightweight satin bomber',
      price: 8500.00,
      rating: 4.6,
      imageUrl:
          'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=600&auto=format&fit=crop&q=85',
      category: 'Jacket',
      colors: ['#B5651D', '#8B4513'],
      sizes: ['S', 'M', 'L'],
      isFavorite: true,
    ),
    const WardrobeItemModel(
      id: 'w15',
      title: 'Blue denim jacket',
      subtitle: 'Classic trucker jacket',
      price: 7000.00,
      rating: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600&auto=format&fit=crop&q=85',
      category: 'Jacket',
      colors: ['#4A6D8C', '#2F4F6F'],
      sizes: ['S', 'M', 'L', 'XL'],
      isFavorite: false,
    ),
    const WardrobeItemModel(
      id: 'w16',
      title: 'Checkered blazer',
      subtitle: 'Tailored windowpane blazer',
      price: 14000.00,
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1600091166971-7f9faad6c1e2?w=600&auto=format&fit=crop&q=85',
      category: 'Jacket',
      colors: ['#3B3B3F', '#1C1C1E'],
      sizes: ['M', 'L', 'XL'],
      isFavorite: false,
    ),
    const WardrobeItemModel(
      id: 'w17',
      title: 'Denim jacket, corduroy collar',
      subtitle: 'Vintage-style trucker jacket',
      price: 7800.00,
      rating: 4.6,
      imageUrl:
          'https://images.unsplash.com/photo-1611312449408-fcece27cdbb7?w=600&auto=format&fit=crop&q=85',
      category: 'Jacket',
      colors: ['#3A5A7A', '#8B6C42'],
      sizes: ['S', 'M', 'L'],
      isFavorite: false,
    ),
    const WardrobeItemModel(
      id: 'w18',
      title: 'Tan leather moto jacket',
      subtitle: 'Structured biker jacket',
      price: 15000.00,
      rating: 4.9,
      imageUrl:
          'https://images.unsplash.com/photo-1487222477894-8943e31ef7b2?w=600&auto=format&fit=crop&q=85',
      category: 'Jacket',
      colors: ['#C19A6B', '#8B6C42'],
      sizes: ['M', 'L'],
      isFavorite: true,
    ),

    // -- Jeans --
    const WardrobeItemModel(
      id: 'w19',
      title: 'Dark wash straight jeans',
      subtitle: 'Classic five-pocket denim',
      price: 5800.00,
      rating: 4.6,
      imageUrl:
          'https://images.unsplash.com/photo-1542272604-787c3835535d?w=600&auto=format&fit=crop&q=85',
      category: 'Jeans',
      colors: ['#2C3E50', '#1C1C1E'],
      sizes: ['28', '30', '32', '34'],
      isFavorite: true,
    ),
    const WardrobeItemModel(
      id: 'w20',
      title: 'Distressed mom jeans',
      subtitle: 'High-rise ripped denim',
      price: 6200.00,
      rating: 4.5,
      imageUrl:
          'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600&auto=format&fit=crop&q=85',
      category: 'Jeans',
      colors: ['#4A6274', '#1C1C1E'],
      sizes: ['XS', 'S', 'M', 'L'],
      isFavorite: false,
    ),
    const WardrobeItemModel(
      id: 'w21',
      title: 'Light wash skinny jeans',
      subtitle: 'Stretch-fit skinny denim',
      price: 5000.00,
      rating: 4.4,
      imageUrl:
          'https://images.unsplash.com/photo-1475178626620-a4d074967452?w=600&auto=format&fit=crop&q=85',
      category: 'Jeans',
      colors: ['#A8C4DC', '#FFFFFF'],
      sizes: ['XS', 'S', 'M', 'L'],
      isFavorite: false,
    ),
    const WardrobeItemModel(
      id: 'w22',
      title: 'High-waisted blue jeans',
      subtitle: 'Relaxed mom-fit denim',
      price: 5500.00,
      rating: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1582418702059-97ebafb35d09?w=600&auto=format&fit=crop&q=85',
      category: 'Jeans',
      colors: ['#3B6BA5', '#1C1C1E'],
      sizes: ['S', 'M', 'L'],
      isFavorite: true,
    ),

    // -- Shoes --
    const WardrobeItemModel(
      id: 'w23',
      title: 'Tan leather sneakers',
      subtitle: 'Everyday low-top sneakers',
      price: 9500.00,
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=600&auto=format&fit=crop&q=85',
      category: 'Shoes',
      colors: ['#B5834D', '#1C1C1E'],
      sizes: ['6', '7', '8', '9', '10'],
      isFavorite: true,
    ),
    const WardrobeItemModel(
      id: 'w24',
      title: 'Pastel shadow sneakers',
      subtitle: 'Layered pastel sneakers',
      price: 11000.00,
      rating: 4.6,
      imageUrl:
          'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600&auto=format&fit=crop&q=85',
      category: 'Shoes',
      colors: ['#F5C6D6', '#C9C6F5'],
      sizes: ['6', '7', '8', '9'],
      isFavorite: false,
    ),
    const WardrobeItemModel(
      id: 'w25',
      title: 'Floral print heels',
      subtitle: 'Satin pointed-toe pumps',
      price: 13000.00,
      rating: 4.5,
      imageUrl:
          'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600&auto=format&fit=crop&q=85',
      category: 'Shoes',
      colors: ['#2C5F8A', '#8B2C4B'],
      sizes: ['6', '7', '8', '9'],
      isFavorite: false,
    ),
    const WardrobeItemModel(
      id: 'w26',
      title: 'Colorblock chunky sneakers',
      subtitle: 'Retro dad-style sneakers',
      price: 10500.00,
      rating: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600&auto=format&fit=crop&q=85',
      category: 'Shoes',
      colors: ['#E8E6E1', '#C0392B'],
      sizes: ['7', '8', '9', '10', '11'],
      isFavorite: true,
    ),
    const WardrobeItemModel(
      id: 'w27',
      title: 'White & orange sneakers',
      subtitle: 'Sporty running sneakers',
      price: 9000.00,
      rating: 4.6,
      imageUrl:
          'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600&auto=format&fit=crop&q=85',
      category: 'Shoes',
      colors: ['#FFFFFF', '#E8590C'],
      sizes: ['7', '8', '9', '10'],
      isFavorite: false,
    ),

    // ----------------------------------------------------
    // SAVED OUTFIT ITEMS
    // ----------------------------------------------------
    const WardrobeItemModel(
      id: 's1',
      title: 'White sweatshirt',
      subtitle: 'Cozy crewneck sweatshirt',
      price: 5500.00,
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
      price: 4800.00,
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
      title: 'White formal shirt',
      subtitle: 'Tailored slim-fit stretch oxford',
      price: 6000.00,
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1603252109303-2751441dd157?w=600&auto=format&fit=crop&q=80',
      category: 'T-shirts',
      colors: ['#FFFFFF', '#F2F2F2'],
      sizes: ['S', 'M', 'L', 'XL'],
      isFavorite: true,
      isSavedOutfit: true,
    ),
    const WardrobeItemModel(
      id: 's4',
      title: 'Assorted shirt collection',
      subtitle: 'Curated capsule of button-ups',
      price: 2100.00,
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
      title: 'Black logo tee',
      subtitle: 'Minimal streetwear logo print',
      price: 7000.00,
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=600&auto=format&fit=crop&q=80',
      category: 'Jacket',
      colors: ['#000000', '#FFFFFF'],
      sizes: ['M', 'L', 'XL'],
      isFavorite: false,
      isSavedOutfit: true,
    ),
    const WardrobeItemModel(
      id: 's6',
      title: 'Yellow co-ord set',
      subtitle: 'Cohesive fashion matching top & bottom',
      price: 11000.00,
      rating: 4.9,
      imageUrl:
          'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600&auto=format&fit=crop&q=80',
      category: 'Crop top',
      colors: ['#F4B400', '#FF8C00'],
      sizes: ['XS', 'S', 'M', 'L'],
      isFavorite: true,
      isSavedOutfit: true,
    ),

    // ----------------------------------------------------
    // MARKETPLACE ITEMS (ADD COLLECTION DISCOVERY)
    // ----------------------------------------------------
    const WardrobeItemModel(
      id: 'm1',
      title: 'Assorted folded shirts',
      subtitle: 'Charcoal, cream & maroon button-ups',
      price: 5000.00,
      rating: 4.5,
      imageUrl:
          'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600&auto=format&fit=crop&q=80',
      category: 'T-shirts',
      colors: ['#3A3A3C', '#EAE5D9', '#7B2D3E'],
      sizes: ['S', 'M', 'L', 'XL'],
      isFavorite: false,
      isMarketplaceItem: true,
    ),
    const WardrobeItemModel(
      id: 'm2',
      title: 'White shirt',
      subtitle: 'Crisp casual linen button-down',
      price: 4000.00,
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
      title: 'Orange sweatshirt',
      subtitle: 'Relaxed-fit crewneck sweatshirt',
      price: 9700.00,
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1578587018452-892bacefd3f2?w=600&auto=format&fit=crop&q=80',
      category: 'Jacket',
      colors: ['#E8590C', '#FF7F32'],
      sizes: ['M', 'L', 'XL'],
      isFavorite: false,
      isMarketplaceItem: true,
    ),
    const WardrobeItemModel(
      id: 'm4',
      title: 'Assorted t-shirt rack',
      subtitle: 'Mixed-color everyday tees',
      price: 2000.00,
      rating: 4.3,
      imageUrl:
          'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=600&auto=format&fit=crop&q=80',
      category: 'T-shirts',
      colors: ['#FFFFFF', '#C0392B', '#F4B400'],
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      isFavorite: false,
      isMarketplaceItem: true,
    ),
    const WardrobeItemModel(
      id: 'm5',
      title: 'Rust bomber jacket',
      subtitle: 'Lightweight satin bomber',
      price: 8000.00,
      rating: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=600&auto=format&fit=crop&q=80',
      category: 'Jacket',
      colors: ['#B5651D', '#8B4513'],
      sizes: ['M', 'L', 'XL'],
      isFavorite: false,
      isMarketplaceItem: true,
    ),
    const WardrobeItemModel(
      id: 'm6',
      title: 'White formal shirt',
      subtitle: 'Relaxed fit dress shirt',
      price: 6700.00,
      rating: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1603252109303-2751441dd157?w=600&auto=format&fit=crop&q=80',
      category: 'T-shirts',
      colors: ['#FFFFFF', '#F2F2F2'],
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
