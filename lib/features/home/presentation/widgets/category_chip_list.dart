import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryChipList extends StatefulWidget {
  const CategoryChipList({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  static const List<String> _categories = [
    'Office',
    'Casual Outings',
    'Formal Party',
    'College',
    'Date Night',
  ];

  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  State<CategoryChipList> createState() => _CategoryChipListState();
}

class _CategoryChipListState extends State<CategoryChipList> {
  late final List<GlobalKey> _categoryKeys = List.generate(
    CategoryChipList._categories.length,
    (_) => GlobalKey(),
  );

  void _selectCategory(int index) {
    widget.onSelected(CategoryChipList._categories[index]);

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
      height: 29,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 15, right: 82),
        itemCount: CategoryChipList._categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final label = CategoryChipList._categories[index];
          final selected = label == widget.selectedCategory;

          return GestureDetector(
            key: _categoryKeys[index],
            onTap: () => _selectCategory(index),
            child: Container(
              height: 28,
              padding: EdgeInsets.only(
                left: selected ? 11 : 12,
                right: selected ? 8 : 9,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white
                    : const Color(0xff686868).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: selected ? Colors.black : const Color(0xffe2e2e2),
                      fontSize: 11.2,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    selected
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.chevron_right_rounded,
                    color: selected ? Colors.black : const Color(0xffd9d9d9),
                    size: 16,
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
