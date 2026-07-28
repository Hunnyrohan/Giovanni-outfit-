import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/wardrobe_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/wardrobe_grid.dart';
import '../widgets/rounded_icon_button.dart';

class SavedOutfitsScreen extends StatefulWidget {
  const SavedOutfitsScreen({super.key});

  @override
  State<SavedOutfitsScreen> createState() => _SavedOutfitsScreenState();
}

class _SavedOutfitsScreenState extends State<SavedOutfitsScreen> {
  final List<String> _categories = ['All', 'T-shirts', 'Crop top', 'Jacket'];
  late final List<GlobalKey> _categoryKeys = List.generate(
    _categories.length,
    (_) => GlobalKey(),
  );

  void _selectCategory(WardrobeProvider wardrobeProvider, int index) {
    wardrobeProvider.setCategory(_categories[index]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _categoryKeys[index].currentContext;
      if (context == null) return;

      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: 0.5,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WardrobeProvider>().fetchSavedOutfits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wardrobeProvider = context.watch<WardrobeProvider>();
    final items = wardrobeProvider.filteredSavedOutfits;

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
                    Color(0xff242020),
                    Color(0xff090909),
                    Color(0xff050505),
                    Color(0xff2b2030),
                  ]
                : const [
                    Color(0xffEDE6DB),
                    Color(0xffF4F2F0),
                    Color(0xffF3F1EF),
                    Color(0xffE8DFE9),
                  ],
            stops: const [0.0, 0.34, 0.72, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Scrollable Content
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar Area
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                        vertical: 7.0,
                      ),
                      child: Row(
                        children: [
                          RoundedIconButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            size: 55,
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/home');
                              }
                            },
                          ),
                          const SizedBox(width: 28),
                          Text(
                            'Saved outfits',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Horizontal Category Chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14.0, bottom: 28.0),
                      child: SizedBox(
                        height: 36,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(left: 18, right: 110),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final cat = _categories[index];
                            final isActive =
                                wardrobeProvider.selectedCategory
                                    .toLowerCase() ==
                                cat.toLowerCase();
                            return Padding(
                              key: _categoryKeys[index],
                              padding: const EdgeInsets.only(right: 12.0),
                              child: CategoryChip(
                                label: cat,
                                isActive: isActive,
                                onTap: () =>
                                    _selectCategory(wardrobeProvider, index),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Product Grid Area
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 19.0),
                    sliver: SliverToBoxAdapter(
                      child: wardrobeProvider.isLoading
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 80.0),
                                child: CircularProgressIndicator(
                                  color: isDark ? Colors.white24 : Colors.black26,
                                ),
                              ),
                            )
                          : WardrobeGrid(
                              items: items,
                              onFavoriteTap: (item) {
                                wardrobeProvider.toggleFavorite(item.id);
                              },
                              onTryVirtuallyTap: (item) {
                                context.push('/virtual-wear', extra: item);
                              },
                              onItemTap: (item) {
                                context.push('/product-details', extra: item);
                              },
                              isMarketplace: true,
                              showRatingDetails: true,
                            ),
                    ),
                  ),

                  // Padding at the bottom for scroll comfort
                  const SliverToBoxAdapter(child: SizedBox(height: 118)),
                ],
              ),

              // Bottom Floating Action Button Center Positioned
              Positioned(
                bottom: 43,
                left: 0,
                right: 0,
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextButton.icon(
                      onPressed: () => context.push('/add-collection'),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(198, 58),
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        backgroundColor: Colors.white.withValues(alpha: 0.88),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(29),
                        ),
                      ),
                      icon: const Icon(
                        Icons.add_rounded,
                        color: Colors.black,
                        size: 26,
                      ),
                      label: Text(
                        'Add collection',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
