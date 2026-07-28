import 'package:flutter/material.dart';

import '../widgets/notification_header.dart';
import '../widgets/notification_section.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const List<NotificationItemData> _todayItems = [
    NotificationItemData(
      name: 'Peter',
      action: 'Liked your outfit',
      time: '40 min ago',
      imageUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=160&auto=format&fit=crop&q=80',
      showThumb: true,
    ),
    NotificationItemData(
      name: 'Kate',
      action: 'Liked your combination',
      time: '2 hr ago',
      imageUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=160&auto=format&fit=crop&q=80',
      showThumb: true,
    ),
    NotificationItemData(
      name: 'Alex',
      action: 'Shared your outfit',
      time: '2 hr ago',
      imageUrl:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=160&auto=format&fit=crop&q=80',
    ),
    NotificationItemData(
      name: 'Julia',
      action: 'Liked your outfit',
      time: '5 hr ago',
      imageUrl:
          'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=160&auto=format&fit=crop&q=80',
      showThumb: true,
    ),
  ];

  static const List<NotificationItemData> _yesterdayItems = [
    NotificationItemData(
      name: 'Steve',
      action: 'Liked your outfit',
      time: '7 hr ago',
      imageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=160&auto=format&fit=crop&q=80',
      showThumb: true,
    ),
    NotificationItemData(
      name: 'Scarlet',
      action: 'Liked your combination',
      time: '7 hr ago',
      imageUrl:
          'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=160&auto=format&fit=crop&q=80',
      showThumb: true,
    ),
    NotificationItemData(
      name: 'Lucky',
      action: 'Shared your outfit',
      time: '8 hr ago',
      imageUrl:
          'https://images.unsplash.com/photo-1507591064344-4c6ce005b128?w=160&auto=format&fit=crop&q=80',
    ),
    NotificationItemData(
      name: 'Gorgia',
      action: 'Liked your outfit',
      time: '8 hr ago',
      imageUrl:
          'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=160&auto=format&fit=crop&q=80',
      showThumb: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xffF3F1EF),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xff302626),
                    Color(0xff0b0b0b),
                    Color(0xff11110e),
                    Color(0xff30222f),
                  ]
                : const [
                    Color(0xffEDE6DB),
                    Color(0xffF4F2F0),
                    Color(0xffF3F1EF),
                    Color(0xffE8DFE9),
                  ],
            stops: const [0, 0.42, 0.72, 1],
          ),
        ),
        child: const SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: NotificationHeader()),
              SliverToBoxAdapter(
                child: NotificationSection(title: 'Today', items: _todayItems),
              ),
              SliverToBoxAdapter(
                child: NotificationSection(
                  title: 'Yesterday',
                  items: _yesterdayItems,
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),
        ),
      ),
    );
  }
}
