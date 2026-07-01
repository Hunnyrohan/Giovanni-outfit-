import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
                Text('705', style: _smallStyle),
                const SizedBox(width: 3),
                const Icon(Icons.star_rounded, color: Color(0xffd8ff1f), size: 9),
                Text(' ${collection.rating}  (21)', style: _smallStyle),
              ],
            ),
            Text(
              collection.title,
              maxLines: 1,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '\$${collection.price.toStringAsFixed(2)}',
                    style: _smallStyle,
                  ),
                ),
                SizedBox(
                  height: 22,
                  child: OutlinedButton(
                    onPressed: () => context.push('/virtual-wear', extra: _wardrobeItem),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      side: const BorderSide(color: Colors.white),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      'Try virtually',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 8.5),
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

  TextStyle get _smallStyle => GoogleFonts.outfit(
    color: Colors.white,
    fontSize: 7,
    fontWeight: FontWeight.w300,
  );
}
