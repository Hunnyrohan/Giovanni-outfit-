import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/currency.dart';

import '../../../wardrobe/domain/entities/wardrobe_item_entity.dart';
import '../../domain/entities/profile_collection_entity.dart';

class ProfileCollectionCard extends StatelessWidget {
  const ProfileCollectionCard({required this.collection, super.key});

  final ProfileCollectionEntity collection;

  WardrobeItemEntity get _wardrobeItem => WardrobeItemEntity(
    id: collection.id,
    title: collection.title,
    subtitle: collection.category,
    price: collection.price,
    rating: collection.rating,
    imageUrl: collection.imageUrl,
    category: collection.category,
    colors: const ['#EAE5D9', '#3A3A3C'],
    sizes: const ['S', 'M', 'L', 'XL'],
    isFavorite: collection.isFavorite,
  );

  @override
  Widget build(BuildContext context) {
    final onScreen = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF1E1E1E);
    final smallStyle = GoogleFonts.outfit(
      color: onScreen,
      fontSize: 7,
      fontWeight: FontWeight.w300,
    );

    return GestureDetector(
      onTap: () => context.push('/product-details', extra: _wardrobeItem),
      child: SizedBox(
        width: 143,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.network(
                collection.imageUrl,
                width: 143,
                height: 155,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Text('705', style: smallStyle),
                const SizedBox(width: 3),
                const Icon(Icons.star_rounded, color: Color(0xffd8ff1f), size: 9),
                Text(' ${collection.rating}  (21)', style: smallStyle),
              ],
            ),
            Text(
              collection.title,
              maxLines: 1,
              style: GoogleFonts.outfit(color: onScreen, fontSize: 13),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    Currency.format(collection.price),
                    style: smallStyle,
                  ),
                ),
                SizedBox(
                  height: 22,
                  child: OutlinedButton(
                    onPressed: () => context.push('/virtual-wear', extra: _wardrobeItem),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      side: BorderSide(color: onScreen),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      'Try virtually',
                      style: GoogleFonts.outfit(color: onScreen, fontSize: 8.5),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
