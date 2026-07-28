import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryTile extends StatefulWidget {
  final String title;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const HistoryTile({
    super.key,
    required this.title,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<HistoryTile> createState() => _HistoryTileState();
}

class _HistoryTileState extends State<HistoryTile> {
  double _opacity = 1.0;

  void _triggerDelete() {
    setState(() {
      _opacity = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final onScreen = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF1E1E1E);

    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      onEnd: () {
        if (_opacity == 0.0) {
          widget.onDelete();
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 58, // Around 48 height, giving a little breathing room for vertical items
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: onScreen,
                    fontSize: 15, // Match screenshot text proportion (it says font size 18, but with scales, 15-16 fits well. Let's make it 16 to be perfectly readable and match design)
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _triggerDelete,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: onScreen,
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
