import '../models/recommended_outfit_model.dart';

class HomeLocalDataSource {
  Future<List<RecommendedOutfitModel>> getRecommendedOutfits() async {
    return const [
      RecommendedOutfitModel(
        id: 'white-minimal-outfit',
        title: 'White Minimal Outfit',
        category: 'Office',
        imageUrl:
            'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=900&q=85',
        isFavorite: false,
        occasion: 'Office',
        description: 'Clean white layers with a refined minimalist finish.',
      ),
      RecommendedOutfitModel(
        id: 'cream-office-blazer',
        title: 'Cream Office Blazer',
        category: 'Office',
        imageUrl:
            'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=900&q=85',
        isFavorite: true,
        occasion: 'Office',
        description: 'Tailored cream blazer for polished workwear styling.',
      ),
      RecommendedOutfitModel(
        id: 'navy-formal-dress',
        title: 'Navy Formal Dress',
        category: 'Formal',
        imageUrl:
            'https://images.unsplash.com/photo-1566174053879-31528523f8ae?auto=format&fit=crop&w=900&q=85',
        isFavorite: false,
        occasion: 'Formal',
        description: 'Structured navy dress for an elegant evening profile.',
      ),
      RecommendedOutfitModel(
        id: 'casual-beige-jacket',
        title: 'Casual Beige Jacket',
        category: 'Casual Outings',
        imageUrl:
            'https://images.unsplash.com/photo-1485968579580-b6d095142e6e?auto=format&fit=crop&w=900&q=85',
        isFavorite: false,
        occasion: 'Casual Outings',
        description: 'Relaxed beige jacket with warm everyday styling.',
      ),
    ];
  }
}
