import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/conversation_history.dart';
import 'history_tile.dart';

class HistorySection extends StatelessWidget {
  final String title;
  final List<ConversationHistory> items;
  final Function(ConversationHistory) onItemTap;
  final Function(String) onItemDelete;

  const HistorySection({
    super.key,
    required this.title,
    required this.items,
    required this.onItemTap,
    required this.onItemDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF1E1E1E))
                  .withValues(alpha: 0.55),
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return HistoryTile(
              title: item.title,
              onTap: () => onItemTap(item),
              onDelete: () => onItemDelete(item.id),
            );
          },
        ),
      ],
    );
  }
}
