import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../injection_container.dart' as di;
import '../../../wardrobe/domain/entities/wardrobe_item_entity.dart';
import '../../domain/entities/try_on_job_entity.dart';
import '../../domain/usecases/delete_try_on_usecase.dart';
import '../../domain/usecases/save_try_on_usecase.dart';

/// Bundles what the result screen needs alongside the completed job: the
/// locally-picked person photo (for the before/after toggle, never uploaded
/// anywhere else) and the source wardrobe item (so "Generate Again" can
/// return to a fresh Virtual Wear screen for the same garment).
class TryOnResultArgs {
  final TryOnJobEntity job;
  final File? originalImage;
  final WardrobeItemEntity? wardrobeItem;

  const TryOnResultArgs({required this.job, this.originalImage, this.wardrobeItem});
}

class VirtualTryOnResultScreen extends StatefulWidget {
  const VirtualTryOnResultScreen({super.key, required this.args});

  final TryOnResultArgs args;

  @override
  State<VirtualTryOnResultScreen> createState() => _VirtualTryOnResultScreenState();
}

class _VirtualTryOnResultScreenState extends State<VirtualTryOnResultScreen> {
  Uint8List? _resultBytes;
  bool _isLoadingImage = true;
  bool _showAfter = true;
  bool _isSaving = false;
  bool _isDownloading = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadResultImage();
  }

  Future<void> _loadResultImage() async {
    final imageUrl = widget.args.job.resultImageUrl;
    if (imageUrl == null) {
      setState(() => _isLoadingImage = false);
      return;
    }

    try {
      final dioClient = di.sl<DioClient>();
      final response = await dioClient.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      setState(() {
        _resultBytes = Uint8List.fromList(response.data as List<int>);
        _isLoadingImage = false;
      });
    } catch (e) {
      setState(() => _isLoadingImage = false);
      if (mounted) _showSnack('Could not load the generated image');
    }
  }

  void _showSnack(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: isError ? const Color(0xffef586c) : const Color(0xff4ade80),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _handleSaveToOutfits() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final result = await di.sl<SaveTryOnUseCase>()(widget.args.job.id);
    if (!mounted) return;
    setState(() => _isSaving = false);

    result.fold(
      (failure) => _showSnack(failure.message),
      (_) => _showSnack('Saved to your outfits', isError: false),
    );
  }

  Future<void> _handleDownload() async {
    if (_isDownloading || _resultBytes == null) return;
    setState(() => _isDownloading = true);

    try {
      final hasAccess = await Gal.hasAccess() || await Gal.requestAccess();
      if (!hasAccess) {
        if (mounted) _showSnack('Photos permission is required to save to your gallery');
        return;
      }
      await Gal.putImageBytes(_resultBytes!, name: 'stylesense_tryon_${widget.args.job.id}');
      if (mounted) _showSnack('Saved to your gallery', isError: false);
    } catch (e) {
      if (mounted) _showSnack('Could not save to gallery: $e');
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _handleShare() async {
    if (_resultBytes == null) return;
    final fileName = 'stylesense_tryon_${widget.args.job.id}.png';
    await Share.shareXFiles(
      [XFile.fromData(_resultBytes!, mimeType: 'image/png', name: fileName)],
      fileNameOverrides: [fileName],
      text: 'Check out my virtual try-on from StyleSense AI!',
    );
  }

  Future<void> _handleDelete() async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);

    final result = await di.sl<DeleteTryOnUseCase>()(widget.args.job.id);
    if (!mounted) return;
    setState(() => _isDeleting = false);

    result.fold(
      (failure) => _showSnack(failure.message),
      (_) {
        if (context.canPop()) {
          context.pop();
        }
        context.go('/wardrobe');
      },
    );
  }

  void _handleGenerateAgain() {
    context.pushReplacement('/virtual-wear', extra: widget.args.wardrobeItem);
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.args.job;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onScreen = isDark ? Colors.white : const Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xff0d0d0d) : const Color(0xffF3F1EF),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.canPop() ? context.pop() : context.go('/wardrobe'),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: onScreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: onScreen, size: 18),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Your Look',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(color: onScreen, fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 42),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _isLoadingImage
                      ? Center(child: CircularProgressIndicator(color: onScreen))
                      : _buildPreview(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _BeforeAfterToggle(
                    showAfter: _showAfter,
                    onChanged: (value) => setState(() => _showAfter = value),
                  ),
                  const SizedBox(height: 20),
                  if (job.processingTime != null)
                    Text(
                      'Generated in ${job.processingTime!.toStringAsFixed(1)}s',
                      style: GoogleFonts.outfit(color: onScreen.withValues(alpha: 0.38), fontSize: 12),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _ActionButton(
                        icon: Icons.bookmark_outline_rounded,
                        label: 'Save',
                        isLoading: _isSaving,
                        onTap: _handleSaveToOutfits,
                      ),
                      _ActionButton(
                        icon: Icons.ios_share_rounded,
                        label: 'Share',
                        onTap: _resultBytes == null ? null : _handleShare,
                      ),
                      _ActionButton(
                        icon: Icons.download_rounded,
                        label: 'Download',
                        isLoading: _isDownloading,
                        onTap: _resultBytes == null ? null : _handleDownload,
                      ),
                      _ActionButton(
                        icon: Icons.delete_outline_rounded,
                        label: 'Delete',
                        isLoading: _isDeleting,
                        onTap: _handleDelete,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _handleGenerateAgain,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffef586c),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        'Generate Again',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_showAfter && _resultBytes != null) {
      return Image.memory(_resultBytes!, fit: BoxFit.cover, width: double.infinity);
    }
    if (!_showAfter && widget.args.originalImage != null) {
      return Image.file(widget.args.originalImage!, fit: BoxFit.cover, width: double.infinity);
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
      child: Center(
        child: Text(
          'Image not available',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white54 : const Color(0xFF6E6A70),
          ),
        ),
      ),
    );
  }
}

class _BeforeAfterToggle extends StatelessWidget {
  const _BeforeAfterToggle({required this.showAfter, required this.onChanged});

  final bool showAfter;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleOption(label: 'Before', isSelected: !showAfter, onTap: () => onChanged(false)),
          _ToggleOption(label: 'After', isSelected: showAfter, onTap: () => onChanged(true)),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onScreen = isDark ? Colors.white : const Color(0xFF1E1E1E);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? onScreen : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : onScreen.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onScreen = isDark ? Colors.white : const Color(0xFF1E1E1E);

    return Expanded(
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: onScreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(14),
                      child: CircularProgressIndicator(color: onScreen, strokeWidth: 2),
                    )
                  : Icon(
                      icon,
                      color: onTap == null ? onScreen.withValues(alpha: 0.24) : onScreen,
                      size: 22,
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.outfit(color: onScreen.withValues(alpha: 0.7), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
