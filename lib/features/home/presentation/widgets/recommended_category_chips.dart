import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommendedCategoryChips extends StatefulWidget {
  const RecommendedCategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  State<RecommendedCategoryChips> createState() =>
      _RecommendedCategoryChipsState();
}

class _RecommendedCategoryChipsState extends State<RecommendedCategoryChips> {
  late List<GlobalKey> _categoryKeys;

  @override
  void initState() {
    super.initState();
    _categoryKeys = List.generate(widget.categories.length, (_) => GlobalKey());
  }

  @override
  void didUpdateWidget(covariant RecommendedCategoryChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories.length != widget.categories.length) {
      _categoryKeys = List.generate(
        widget.categories.length,
        (_) => GlobalKey(),
      );
    }
  }

  void _selectCategory(int index) {
    widget.onSelected(widget.categories[index]);

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
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 24, right: 110),
        physics: const BouncingScrollPhysics(),
        itemCount: widget.categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          final isSelected = category == widget.selectedCategory;
          return GestureDetector(
            key: _categoryKeys[index],
            onTap: () => _selectCategory(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.only(left: 14, right: 9),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category,
                    style: GoogleFonts.poppins(
                      color: isSelected
                          ? const Color(0xff171717)
                          : Colors.white.withValues(alpha: 0.72),
                      fontSize: 12.8,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isSelected
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.chevron_right_rounded,
                    color: isSelected
                        ? const Color(0xff171717)
                        : Colors.white.withValues(alpha: 0.65),
                    size: 19,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
