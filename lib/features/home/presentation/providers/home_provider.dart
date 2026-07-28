import 'package:flutter/foundation.dart';

import '../../domain/entities/recommended_outfit_entity.dart';
import '../../domain/usecases/get_recommended_outfits_usecase.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider({
    required GetRecommendedOutfitsUseCase getRecommendedOutfitsUseCase,
  }) : this._(getRecommendedOutfitsUseCase);

  HomeProvider._(this._getRecommendedOutfitsUseCase);

  final GetRecommendedOutfitsUseCase _getRecommendedOutfitsUseCase;

  final List<String> categories = const [
    'Office',
    'Casual Outings',
    'Formal',
    'College',
    'Date Night',
  ];

  List<RecommendedOutfitEntity> _outfits = [];
  String _selectedCategory = 'Office';
  bool _isLoading = false;

  List<RecommendedOutfitEntity> get outfits => List.unmodifiable(_outfits);
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  List<RecommendedOutfitEntity> get filteredOutfits {
    if (_selectedCategory == 'Office') {
      return List.unmodifiable(_outfits);
    }

    final matches = _outfits
        .where((outfit) => outfit.category == _selectedCategory)
        .toList(growable: false);
    return matches.isEmpty ? List.unmodifiable(_outfits) : matches;
  }

  Future<void> loadRecommendedOutfits() async {
    _isLoading = true;
    notifyListeners();

    _outfits = await _getRecommendedOutfitsUseCase();

    _isLoading = false;
    notifyListeners();
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleFavorite(String outfitId) {
    _outfits = _outfits
        .map((outfit) {
          if (outfit.id != outfitId) return outfit;
          return outfit.copyWith(isFavorite: !outfit.isFavorite);
        })
        .toList(growable: false);
    notifyListeners();
  }
}
