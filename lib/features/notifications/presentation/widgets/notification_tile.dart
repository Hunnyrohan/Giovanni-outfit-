import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'notification_section.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({required this.item, super.key});

  final NotificationItemData item;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 57,
      padding: const EdgeInsets.fromLTRB(13, 8, 12, 7),
      decoration: BoxDecoration(
        color: const Color(0xff545454).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              width: 42,
              height: 42,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 42,
                height: 42,
                color: const Color(0xff777777),
              ),
              errorWidget: (context, url, error) => Container(
                width: 42,
                height: 42,
                color: const Color(0xff777777),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white70,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${item.name} · ${item.action}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 12.8,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    if (item.showThumb) ...[
                      const SizedBox(width: 5),
                      const Text('👍', style: TextStyle(fontSize: 12)),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.time,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
