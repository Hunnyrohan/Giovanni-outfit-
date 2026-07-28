import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/profile_collection_entity.dart';
import 'profile_collection_card.dart';

class ProfileCollectionSection extends StatelessWidget {
  const ProfileCollectionSection({
    required this.collections,
    required this.collectionCount,
    required this.likesCount,
    super.key,
  });

  final List<ProfileCollectionEntity> collections;
  final int collectionCount;
  final String likesCount;

  @override
  Widget build(BuildContext context) {
    final headerStyle = _headerStyleOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Collections', style: headerStyle),
            const SizedBox(width: 5),
            Text(
              '($collectionCount)',
              style: GoogleFonts.outfit(color: const Color(0xff006dff), fontSize: 16),
            ),
            const Spacer(),
            Text(
              '$likesCount likes',
              maxLines: 1,
              style: headerStyle.copyWith(fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 220,
          child: ListView.separated(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: collections.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) =>
                ProfileCollectionCard(collection: collections[index]),
          ),
        ),
      ],
    );
  }

  TextStyle _headerStyleOf(BuildContext context) => GoogleFonts.outfit(
    color: Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF1E1E1E),
    fontSize: 17,
    fontWeight: FontWeight.w400,
  );
}
