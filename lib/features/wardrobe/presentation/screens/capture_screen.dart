import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/wardrobe_item_entity.dart';
import '../providers/wardrobe_provider.dart';
import '../widgets/rounded_icon_button.dart';

/// Two modes:
///  - With [item] (from marketplace/product flows): shows that item's image
///    for confirmation, as before.
///  - Without [item]: a REAL camera capture flow - opens the device camera,
///    previews the shot, lets the user retake, and on confirm uploads the
///    photo as a new wardrobe item on the backend (name + category asked in
///    a bottom sheet).
class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key, this.item});

  final WardrobeItemEntity? item;

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _captured;
  bool _cameraFailed = false;

  bool get _isCameraMode => widget.item == null;

  @override
  void initState() {
    super.initState();
    if (_isCameraMode) {
      // Launch the camera as soon as the screen opens.
      WidgetsBinding.instance.addPostFrameCallback((_) => _openCamera());
    }
  }

  Future<void> _openCamera() async {
    try {
      final shot = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 1600,
      );
      if (!mounted) return;
      setState(() {
        if (shot != null) {
          _captured = File(shot.path);
        }
        _cameraFailed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _cameraFailed = true);
      _snack('Could not open the camera on this device', isError: true);
    }
  }

  void _snack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.outfit(
            color: isError ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isError ? const Color(0xffef586c) : const Color(0xffd6ff00),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _confirmCapture() async {
    if (_captured == null) {
      await _openCamera();
      return;
    }

    final saved = await _showDetailsSheet();
    if (saved == true && mounted) {
      _snack('Added to your wardrobe!');
      context.go('/wardrobe');
    }
  }

  /// Asks for a name + category, uploads, and pops with `true` on success.
  Future<bool?> _showDetailsSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? Colors.white : const Color(0xFF1E1E1E);
    final nameController = TextEditingController();
    String selectedCategory = 'T-shirts';

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xff1c1c1e) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final provider = sheetContext.watch<WardrobeProvider>();

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add to wardrobe',
                  style: GoogleFonts.outfit(
                    color: onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  style: GoogleFonts.outfit(color: onSurface, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Item name (e.g. Blue denim jacket)',
                    hintStyle: GoogleFonts.outfit(
                      color: onSurface.withValues(alpha: 0.4),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: onSurface.withValues(alpha: 0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final label in WardrobeProvider.captureCategories.keys)
                      ChoiceChip(
                        label: Text(
                          label,
                          style: GoogleFonts.outfit(
                            color: selectedCategory == label
                                ? (isDark ? Colors.black : Colors.white)
                                : onSurface,
                            fontSize: 13,
                          ),
                        ),
                        selected: selectedCategory == label,
                        selectedColor: onSurface,
                        backgroundColor: onSurface.withValues(alpha: 0.06),
                        showCheckmark: false,
                        onSelected: (_) =>
                            setSheetState(() => selectedCategory = label),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: provider.isAddingItem
                        ? null
                        : () async {
                            final name = nameController.text.trim();
                            if (name.length < 2) {
                              _snack('Give the item a name first', isError: true);
                              return;
                            }
                            final ok = await sheetContext
                                .read<WardrobeProvider>()
                                .addCapturedItem(
                                  name: name,
                                  displayCategory: selectedCategory,
                                  image: _captured!,
                                );
                            if (!sheetContext.mounted) return;
                            if (ok) {
                              Navigator.pop(sheetContext, true);
                            } else {
                              _snack(
                                provider.addItemError ?? 'Could not save the item',
                                isError: true,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: onSurface,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      disabledBackgroundColor: onSurface.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: provider.isAddingItem
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                          )
                        : Text(
                            'Save to wardrobe',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onScreen = isDark ? Colors.white : const Color(0xFF1E1E1E);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: isDark
                ? const [
                    Color(
                      0xff3a3530,
                    ), // Slightly warmer center glow for camera context
                    Color(0xff121212),
                    Color(0xff050505),
                  ]
                : const [
                    Color(0xffEFE7DA),
                    Color(0xffF3F1EF),
                    Color(0xffEDEAEC),
                  ],
            stops: const [0.0, 0.7, 1.0],
            center: const Alignment(-0.5, -0.2),
            radius: 1.5,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // App Bar Area (Back button on left)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: RoundedIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => context.pop(),
                  ),
                ),
              ),

              const Spacer(),

              // Subtitle/Prompt in Center
              Text(
                widget.item != null
                    ? widget.item!.title
                    : _captured != null
                        ? 'Confirm to add to your wardrobe'
                        : _cameraFailed
                            ? 'Camera unavailable - tap Retake to try again'
                            : 'Take a photo of your clothing item',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: onScreen,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),

              // Center Product Capture Preview Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: AspectRatio(
                  aspectRatio: 0.85, // Standard vertical preview
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: onScreen.withValues(alpha: 0.1),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                          blurRadius: 25,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: _buildPreview(isDark),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Bottom Retake / Confirm Row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 24.0,
                ),
                child: Row(
                  children: [
                    // Retake (Outlined glassmorphic button)
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _isCameraMode ? _openCamera : () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: onScreen.withValues(alpha: 0.3),
                              width: 1.0,
                            ),
                            backgroundColor: onScreen.withValues(
                              alpha: 0.05,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isCameraMode ? Icons.camera_alt_outlined : Icons.close,
                                color: onScreen,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Retake',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: onScreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Confirm (Solid button)
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_isCameraMode) {
                              _confirmCapture();
                            } else {
                              _snack('${widget.item?.title ?? 'Item'} successfully added to Wardrobe!');
                              context.go('/wardrobe');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.white : const Color(0xFF1E1E1E),
                            foregroundColor: isDark ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check,
                                color: isDark ? Colors.black : Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Confirm',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.black : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Safe-area indicator spacing at bottom
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(bool isDark) {
    // Marketplace/product confirmation mode: show that item's image.
    if (widget.item != null) {
      return Image.network(
        widget.item!.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholder(isDark),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: isDark ? const Color(0xff1c1c1e) : const Color(0xffE7E3DF),
            child: Center(
              child: CircularProgressIndicator(
                color: isDark ? Colors.white24 : Colors.black26,
              ),
            ),
          );
        },
      );
    }

    // Camera mode: show the captured shot, or a tappable placeholder.
    if (_captured != null) {
      return GestureDetector(
        onTap: _openCamera,
        child: Image.file(_captured!, fit: BoxFit.cover),
      );
    }
    return GestureDetector(onTap: _openCamera, child: _placeholder(isDark));
  }

  Widget _placeholder(bool isDark) {
    return Container(
      color: isDark ? const Color(0xff1c1c1e) : const Color(0xffE7E3DF),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              color: isDark ? Colors.white38 : Colors.black38,
              size: 56,
            ),
            const SizedBox(height: 10),
            Text(
              'Tap to open camera',
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
