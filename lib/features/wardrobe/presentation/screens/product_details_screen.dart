import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/wardrobe_item_entity.dart';
import '../providers/wardrobe_provider.dart';
import '../widgets/size_option_chip.dart';
import '../widgets/color_dot.dart';
import '../widgets/rounded_icon_button.dart';

class ProductDetailsScreen extends StatefulWidget {
  final WardrobeItemEntity? item;

  const ProductDetailsScreen({super.key, this.item});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  // Local Interactive States
  late String _selectedSize;
  late int _selectedColorIndex;
  late int _activeCarouselIndex;
  
  // Custom styled swatches mapping
  final List<Color> _swatchColors = [
    const Color(0xffeae5d9), // Cream
    const Color(0xffef586c), // Red/coral
    const Color(0xff3a3a3c), // Dark grey
  ];

  @override
  void initState() {
    super.initState();
    // Initialize interactive size options
    final itemSizes = widget.item?.sizes ?? ['S', 'M', 'L', 'XL'];
    _selectedSize = itemSizes.contains('M') ? 'M' : itemSizes.first;
    _selectedColorIndex = 0;
    _activeCarouselIndex = 1; // Highlighting third dot matching reference image
  }

  @override
  Widget build(BuildContext context) {
    // Fallback Mock Item if none passed through router extra state
    final item = widget.item ?? const WardrobeItemEntity(
      id: 'mock_detail',
      title: 'Two tone long-sleeve shirt',
      subtitle: 'Colorblocked heavyweight knit',
      price: 21.00,
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=800&auto=format&fit=crop&q=80',
      category: 'T-shirts',
      colors: ['#EAE5D9', '#EF586C', '#3A3A3C'],
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      isFavorite: true,
    );

    final wardrobeProvider = context.watch<WardrobeProvider>();
    final isFavorite = widget.item != null 
        ? wardrobeProvider.wardrobeItems.any((e) => e.id == item.id && e.isFavorite) 
            || wardrobeProvider.savedOutfits.any((e) => e.id == item.id && e.isFavorite) 
            || wardrobeProvider.marketplaceItems.any((e) => e.id == item.id && e.isFavorite)
        : item.isFavorite;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xff2d231b), // Soft warm ambient center glow
              Color(0xff121212),
              Color(0xff050505),
            ],
            stops: [0.0, 0.7, 1.0],
            center: Alignment(-0.5, -0.2),
            radius: 1.5,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top Custom App Bar Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RoundedIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => context.pop(),
                    ),
                    Text(
                      'Product Details',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    RoundedIconButton(
                      icon: Icons.share_rounded,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Product details link copied to clipboard!',
                              style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: Colors.white,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Scrollable Details Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image Display
                      Container(
                        width: double.infinity,
                        height: 310,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: const Color(0xff1c1c1e),
                                child: const Center(
                                  child: CircularProgressIndicator(color: Colors.white24),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Image Carousel Indicator Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final isActive = index == _activeCarouselIndex;
                          return GestureDetector(
                            onTap: () => setState(() => _activeCarouselIndex = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                              width: isActive ? 20.0 : 6.0,
                              height: 6.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: isActive ? Colors.white : Colors.white24,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),

                      // Title & Price Section
                      Text(
                        item.title,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$ ${item.price.toInt()}',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xffd6ff00), // Lime green price accent
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Description Box
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: const Color(0xffbdbdbd),
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(
                              text: 'The body of the garment is white, while the sleeves are navy blue, creating a classic and versatile look. A tag is visible at the back of the collar, which might contain brand or care instructions... ',
                            ),
                            TextSpan(
                              text: 'more details',
                              style: GoogleFonts.outfit(
                                color: const Color(0xffd6ff00),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sizes Selector Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: item.sizes.map((sz) {
                          final isSelected = _selectedSize == sz;
                          return SizeOptionChip(
                            size: sz,
                            isSelected: isSelected,
                            onTap: () => setState(() => _selectedSize = sz),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Color selector Row
                      Row(
                        children: [
                          ...List.generate(_swatchColors.length, (idx) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: ColorDot(
                                color: _swatchColors[idx],
                                isSelected: _selectedColorIndex == idx,
                                onTap: () => setState(() => _selectedColorIndex = idx),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Bottom Favorite & Buy Action Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0).copyWith(
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                ),
                child: Row(
                  children: [
                    // Favorite Toggle Circle
                    GestureDetector(
                      onTap: () {
                        if (widget.item != null) {
                          wardrobeProvider.toggleFavorite(item.id);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added mock to favorites!',
                                style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: Colors.white,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1.0,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? const Color(0xffef586c) : Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // "Buy now" rounded pill button
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Thank you! Purchasing simulated for size $_selectedSize.',
                                  style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: const Color(0xffd6ff00),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Buy now',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
