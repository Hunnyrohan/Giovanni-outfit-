import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteAllButton extends StatelessWidget {
  final VoidCallback onTap;

  const DeleteAllButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          'Delete all',
          style: GoogleFonts.poppins(
            color: Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
