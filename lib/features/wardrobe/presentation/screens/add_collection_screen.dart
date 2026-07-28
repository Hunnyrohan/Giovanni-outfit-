import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/wardrobe_provider.dart';
import '../widgets/wardrobe_search_bar.dart';
import '../widgets/wardrobe_grid.dart';
import '../widgets/rounded_icon_button.dart';

class AddCollectionScreen extends StatefulWidget {
  const AddCollectionScreen({super.key});

  @override
  State<AddCollectionScreen> createState() => _AddCollectionScreenState();
}

class _AddCollectionScreenState extends State<AddCollectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WardrobeProvider>().fetchMarketplaceItems();
      context.read<WardrobeProvider>().setSearchQuery(
        '',
      ); // Reset search on open
    });
  }

  @override
  Widget build(BuildContext context) {
    final wardrobeProvider = context.watch<WardrobeProvider>();
    final items = wardrobeProvider.filteredMarketplaceItems;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: isDark
                ? const [
                    Color(0xff2d231b), // Soft warm glow
                    Color(0xff121212), // Dark grey
                    Color(0xff050505), // Ultra black
                  ]
                : const [
                    Color(0xffEDE4D4), // Soft warm glow
                    Color(0xffF3F1EF),
                    Color(0xffEAE4EA),
                  ],
            stops: const [0.0, 0.7, 1.0],
            center: const Alignment(-0.5, -0.2),
            radius: 1.5,
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
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      child: Row(
                        children: [
                          RoundedIconButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/wardrobe');
                              }
                            },
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Add collection',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search Bar Area
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                      ).copyWith(bottom: 24.0),
                      child: WardrobeSearchBar(
                        onChanged: (value) {
                          wardrobeProvider.setSearchQuery(value);
                        },
                      ),
                    ),
                  ),

                  // Product Grid Area
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                              isMarketplace: true,
                              showRatingDetails: true,
                              onFavoriteTap: (item) {
                                wardrobeProvider.toggleFavorite(item.id);
                              },
                              onTryVirtuallyTap: (item) {
                                context.push('/virtual-wear', extra: item);
                              },
                              onItemTap: (item) {
                                context.push('/product-details', extra: item);
                              },
                            ),
                    ),
                  ),

                  // Padding at the bottom for scroll comfort
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),

              // Bottom Floating Action Button Center Positioned (Camera CTA)
              Positioned(
                bottom: 28,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => context.push('/capture'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withValues(
                          alpha: 0.08,
                        ), // Translucent glassmorphic style
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Capture from camera',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
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
