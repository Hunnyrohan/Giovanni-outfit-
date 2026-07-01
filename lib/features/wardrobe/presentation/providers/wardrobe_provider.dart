import 'package:flutter/material.dart';
import '../../domain/entities/wardrobe_item_entity.dart';
import '../../domain/usecases/get_wardrobe_items_usecase.dart';
import '../../domain/usecases/get_saved_outfits_usecase.dart';
import '../../domain/usecases/get_marketplace_items_usecase.dart';
import '../../domain/repositories/wardrobe_repository.dart';

class WardrobeProvider extends ChangeNotifier {
  final GetWardrobeItemsUseCase getWardrobeItemsUseCase;
  final GetSavedOutfitsUseCase getSavedOutfitsUseCase;
  final GetMarketplaceItemsUseCase getMarketplaceItemsUseCase;
  final WardrobeRepository repository; // Directly used for toggle/add to follow strict UI decoupling

  WardrobeProvider({
    required this.getWardrobeItemsUseCase,
    required this.getSavedOutfitsUseCase,
    required this.getMarketplaceItemsUseCase,
    required this.repository,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<WardrobeItemEntity> _wardrobeItems = [];
  List<WardrobeItemEntity> get wardrobeItems => _wardrobeItems;

  List<WardrobeItemEntity> _savedOutfits = [];
  List<WardrobeItemEntity> get savedOutfits => _savedOutfits;

  List<WardrobeItemEntity> _marketplaceItems = [];
  List<WardrobeItemEntity> get marketplaceItems => _marketplaceItems;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Filtered lists
  List<WardrobeItemEntity> get filteredWardrobeItems {
    if (_selectedCategory == 'All') {
      return _wardrobeItems;
    }
    return _wardrobeItems.where((e) => e.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
  }

  List<WardrobeItemEntity> get filteredSavedOutfits {
    if (_selectedCategory == 'All') {
      return _savedOutfits;
    }
    return _savedOutfits.where((e) => e.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
  }

  List<WardrobeItemEntity> get filteredMarketplaceItems {
    final list = _marketplaceItems;
    if (_searchQuery.isEmpty) {
      return list;
    }
    return list.where((e) => e.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchWardrobeItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      _wardrobeItems = await getWardrobeItemsUseCase();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchSavedOutfits() async {
    _isLoading = true;
    notifyListeners();
    try {
      _savedOutfits = await getSavedOutfitsUseCase();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMarketplaceItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      _marketplaceItems = await getMarketplaceItemsUseCase();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    try {
      await repository.toggleFavorite(id);
      
      // Update local state in-memory so UI updates instantly
      final wIdx = _wardrobeItems.indexWhere((e) => e.id == id);
      if (wIdx != -1) {
        final item = _wardrobeItems[wIdx];
        _wardrobeItems[wIdx] = item.copyWith(isFavorite: !item.isFavorite);
      }

      final sIdx = _savedOutfits.indexWhere((e) => e.id == id);
      if (sIdx != -1) {
        final item = _savedOutfits[sIdx];
        _savedOutfits[sIdx] = item.copyWith(isFavorite: !item.isFavorite);
      }

      final mIdx = _marketplaceItems.indexWhere((e) => e.id == id);
      if (mIdx != -1) {
        final item = _marketplaceItems[mIdx];
        _marketplaceItems[mIdx] = item.copyWith(isFavorite: !item.isFavorite);
      }

      notifyListeners();
    } catch (_) {}
  }

  Future<void> addToWardrobe(WardrobeItemEntity item) async {
    try {
      await repository.addToWardrobe(item);
      
      // Instantly add to wardrobe in-memory
      final exists = _wardrobeItems.any((e) => e.id == item.id);
      if (!exists) {
        _wardrobeItems.add(item.copyWith(isMarketplaceItem: false, isSavedOutfit: false));
      }
      
      // Remove from marketplace or keep it
      notifyListeners();
    } catch (_) {}
  }
}
