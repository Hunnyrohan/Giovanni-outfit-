import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/history_provider.dart';
import '../providers/ai_stylist_provider.dart';
import '../widgets/chat_history_header.dart';
import '../widgets/history_section.dart';
import '../widgets/delete_all_button.dart';
import '../widgets/new_chat_button.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  void _confirmDeleteAll(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? Colors.white : const Color(0xFF1E1E1E);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
          title: Text(
            'Delete All History',
            style: GoogleFonts.poppins(color: onSurface, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to clear your entire chat history? This action cannot be undone.',
            style: GoogleFonts.poppins(color: onSurface.withValues(alpha: 0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: onSurface.withValues(alpha: 0.54)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<HistoryProvider>().deleteAllConversations();
              },
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyProvider = context.watch<HistoryProvider>();
    final stylistProvider = context.read<AiStylistProvider>();

    final now = DateTime.now();
    final todayItems = historyProvider.historyList.where((item) {
      return item.createdAt.year == now.year &&
          item.createdAt.month == now.month &&
          item.createdAt.day == now.day;
    }).toList();

    final yesterdayItems = historyProvider.historyList.where((item) {
      final isToday = item.createdAt.year == now.year &&
          item.createdAt.month == now.month &&
          item.createdAt.day == now.day;
      return !isToday;
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient matching premium dark style
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xff0d0d0d) : const Color(0xffF3F1EF),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: isDark
                      ? [
                          const Color(0xff342527).withValues(alpha: 0.85),
                          const Color(0xff111111),
                          const Color(0xff140b20),
                        ]
                      : const [
                          Color(0xffE7DFD3),
                          Color(0xffF3F1EF),
                          Color(0xffECE7E9),
                        ],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
          ),

          // Main Layout Content
          SafeArea(
            child: Column(
              children: [
                // Top Header Section
                const Padding(
                  padding: EdgeInsets.only(top: 24.0, left: 20.0, right: 20.0, bottom: 12),
                  child: ChatHistoryHeader(),
                ),

                // Scrollable List Section
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    children: [
                      if (todayItems.isNotEmpty)
                        HistorySection(
                          title: 'Today',
                          items: todayItems,
                          onItemTap: (item) {
                            stylistProvider.loadConversation(item);
                            context.push('/ai-stylist');
                          },
                          onItemDelete: (id) {
                            historyProvider.deleteConversation(id);
                          },
                        ),
                      if (yesterdayItems.isNotEmpty)
                        HistorySection(
                          title: 'Yesterday',
                          items: yesterdayItems,
                          onItemTap: (item) {
                            stylistProvider.loadConversation(item);
                            context.push('/ai-stylist');
                          },
                          onItemDelete: (id) {
                            historyProvider.deleteConversation(id);
                          },
                        ),
                      if (historyProvider.historyList.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: DeleteAllButton(
                            onTap: () => _confirmDeleteAll(context),
                          ),
                        ),
                      ],
                      if (historyProvider.historyList.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 80.0),
                          child: Center(
                            child: Text(
                              'No conversation history',
                              style: GoogleFonts.poppins(
                                color: isDark ? Colors.white38 : Colors.black38,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 100), // Spacing to prevent overlay with bottom button
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Centered "New chat" Button
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: NewChatButton(
                onTap: () {
                  stylistProvider.startNewConversation();
                  context.push('/ai-stylist');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
