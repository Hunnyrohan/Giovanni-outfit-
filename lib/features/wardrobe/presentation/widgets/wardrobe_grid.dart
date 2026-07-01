import 'package:flutter/material.dart';
import '../../domain/entities/wardrobe_item_entity.dart';
import 'wardrobe_product_card.dart';

class WardrobeGrid extends StatelessWidget {
  final List<WardrobeItemEntity> items;
  final Function(WardrobeItemEntity) onFavoriteTap;
  final Function(WardrobeItemEntity) onTryVirtuallyTap;
  final Function(WardrobeItemEntity) onItemTap;
  final bool showTryVirtually;
  final bool isMarketplace;
  final bool showRatingDetails;

  const WardrobeGrid({
    super.key,
    required this.items,
    required this.onFavoriteTap,
    required this.onTryVirtuallyTap,
    required this.onItemTap,
    this.showTryVirtually = true,
    this.isMarketplace = false,
    this.showRatingDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white24,
                size: 64,
              ),
              const SizedBox(height: 12),
              Text(
                'No items found',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 8,
        childAspectRatio: 0.72,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return WardrobeProductCard(
          imageUrl: item.imageUrl,
          title: item.title,
          subtitle: isMarketplace ? item.subtitle : 'last worn 4 days ago',
          price: isMarketplace ? item.price : null,
          rating: (isMarketplace || item.isSavedOutfit) ? item.rating : null,
          isFavorite: item.isFavorite,
          onFavoriteTap: () => onFavoriteTap(item),
          onTryVirtuallyTap: () => onTryVirtuallyTap(item),
          onTap: () => onItemTap(item),
          showTryVirtually: showTryVirtually,
          showRatingDetails: showRatingDetails,
        );
      },
    );
  }
}
