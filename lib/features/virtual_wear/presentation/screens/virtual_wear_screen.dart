import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../injection_container.dart' as di;
import '../../../wardrobe/domain/entities/wardrobe_item_entity.dart';
import '../../domain/entities/try_on_job_entity.dart';
import '../providers/virtual_wear_provider.dart';
import '../widgets/hold_still_badge.dart';
import '../widgets/pose_detection_overlay.dart';
import '../widgets/virtual_wear_bottom_controls.dart';
import '../widgets/virtual_wear_header.dart';
import 'virtual_tryon_result_screen.dart';

class VirtualWearScreen extends StatelessWidget {
  const VirtualWearScreen({super.key, this.item});

  final WardrobeItemEntity? item;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di.sl<VirtualWearProvider>()..initialize(item),
      child: const _VirtualWearView(),
    );
  }
}

class _VirtualWearView extends StatefulWidget {
  const _VirtualWearView();

  @override
  State<_VirtualWearView> createState() => _VirtualWearViewState();
}

class _VirtualWearViewState extends State<_VirtualWearView> {
  static const String _bodyPreviewAsset =
      'assets/images/virtual_wear/body_preview.png';
  static const String _bodyPreviewFallback =
      'https://images.unsplash.com/photo-1512316609839-ce289d3eba0a'
      '?auto=format&fit=crop&w=900&q=85';

  TryOnStatus? _lastNavigatedStatus;

  Future<void> _showImageSourceSheet(BuildContext context) async {
    final provider = context.read<VirtualWearProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? Colors.white : const Color(0xFF1E1E1E);

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: isDark ? const Color(0xff1c1c1e) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: onSurface),
              title: Text('Take a photo', style: GoogleFonts.outfit(color: onSurface)),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: onSurface),
              title: Text('Choose from gallery', style: GoogleFonts.outfit(color: onSurface)),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source != null) {
      await provider.pickPersonImage(source);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VirtualWearProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final error = provider.errorMessage;
      if (error != null) {
        provider.clearError();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, style: GoogleFonts.outfit(color: Colors.white)),
            backgroundColor: const Color(0xffef586c),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }

      final job = provider.currentJob;
      if (job != null && job.isTerminal && _lastNavigatedStatus != job.status) {
        _lastNavigatedStatus = job.status;
        if (job.status == TryOnStatus.completed) {
          context.push(
            '/virtual-tryon-result',
            extra: TryOnResultArgs(
              job: job,
              originalImage: provider.personImage,
              wardrobeItem: provider.selectedItem,
            ),
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            key: const Key('virtual_wear_photo_tap_area'),
            onTap: provider.isSubmitting ? null : () => _showImageSourceSheet(context),
            child: Transform.scale(
              scale: 1.18,
              alignment: const Alignment(0, -0.22),
              child: provider.personImage != null
                  ? Image.file(
                      provider.personImage!,
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, -0.18),
                    )
                  : Image.asset(
                      _bodyPreviewAsset,
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, -0.18),
                      errorBuilder: (context, error, stackTrace) {
                        return Image.network(
                          _bodyPreviewFallback,
                          fit: BoxFit.cover,
                          alignment: const Alignment(0, -0.18),
                        );
                      },
                    ),
            ),
          ),
          // Both gradient overlays must be IgnorePointer: DecoratedBox claims
          // hit-tests across its whole surface, and as later Stack siblings
          // they sit above the photo GestureDetector - without this, every
          // tap on the photo area is swallowed and the picker never opens.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0, 0.48, 1],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.92,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.44),
                    ],
                    stops: const [0.62, 1],
                  ),
                ),
              ),
            ),
          ),
          const PoseDetectionOverlay(),
          const VirtualWearHeader(),
          if (provider.personImage == null && !provider.isSubmitting)
            Positioned(
              left: 0,
              right: 0,
              top: 140,
              child: IgnorePointer(
                child: Center(
                  child: Text(
                    'Tap to add your photo',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      shadows: const [Shadow(blurRadius: 8, color: Colors.black)],
                    ),
                  ),
                ),
              ),
            )
          else
            const HoldStillBadge(),
          const VirtualWearBottomControls(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Center(
              child: Container(
                width: 120,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          if (provider.isSubmitting)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.6),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        provider.currentJob == null
                            ? 'Starting generation...'
                            : 'Generating your look...',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
