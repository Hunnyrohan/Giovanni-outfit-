import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class MessageInput extends StatefulWidget {
  final File? selectedImage;
  final Function(ImageSource) onPickImage;
  final VoidCallback onClearImage;
  final Function(String) onSendMessage;

  const MessageInput({
    super.key,
    required this.selectedImage,
    required this.onPickImage,
    required this.onClearImage,
    required this.onSendMessage,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text;
    if (text.trim().isNotEmpty || widget.selectedImage != null) {
      widget.onSendMessage(text);
      _controller.clear();
    }
  }

  void _showImageSourceSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? Colors.white : const Color(0xFF1E1E1E);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: onSurface),
                title: Text('Camera', style: GoogleFonts.poppins(color: onSurface)),
                onTap: () {
                  Navigator.pop(context);
                  widget.onPickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: onSurface),
                title: Text('Gallery', style: GoogleFonts.poppins(color: onSurface)),
                onTap: () {
                  Navigator.pop(context);
                  widget.onPickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? Colors.white : const Color(0xFF1E1E1E);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.selectedImage != null)
          Container(
            margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
            alignment: Alignment.centerLeft,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    widget.selectedImage!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: GestureDetector(
                    onTap: widget.onClearImage,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xff424242).withValues(alpha: 0.9)
                        : Colors.black.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 6),
                      // Camera Button
                      IconButton(
                        onPressed: () => _showImageSourceSelector(context),
                        icon: Icon(
                          Icons.camera_alt_outlined,
                          color: onSurface,
                          size: 22,
                        ),
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(40, 40),
                        ),
                      ),
                      SizedBox(
                        height: 24,
                        child: VerticalDivider(
                          color: onSurface.withValues(alpha: 0.3),
                          width: 12,
                          thickness: 1,
                        ),
                      ),
                      // TextField
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: GoogleFonts.poppins(
                            color: onSurface,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'I want to wear a dress for night party.',
                            hintStyle: GoogleFonts.poppins(
                              color: onSurface.withValues(alpha: 0.5),
                              fontSize: 13.5,
                            ),
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Send Button
              GestureDetector(
                onTap: _handleSend,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: onSurface,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.send_rounded,
                      color: isDark ? Colors.black : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
