import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'notification_tile.dart';

class NotificationItemData {
  const NotificationItemData({
    required this.name,
    required this.action,
    required this.time,
    required this.imageUrl,
    this.showThumb = false,
  });

  final String name;
  final String action;
  final String time;
  final String imageUrl;
  final bool showThumb;
}

class NotificationSection extends StatelessWidget {
  const NotificationSection({
    required this.title,
    required this.items,
    super.key,
  });

  final String title;
  final List<NotificationItemData> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(7, 0, 7, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: GoogleFonts.outfit(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xffa6a6a6)
                    : const Color(0xFF6E6A70),
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: NotificationTile(item: item),
            ),
          ),
        ],
      ),
    );
  }
}
