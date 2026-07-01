import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/virtual_wear_provider.dart';
import '../widgets/clothing_selector_panel.dart';
import '../widgets/hold_still_badge.dart';
import '../widgets/pose_detection_overlay.dart';
import '../widgets/virtual_wear_bottom_controls.dart';
import '../widgets/virtual_wear_header.dart';

class VirtualWearScreen extends StatelessWidget {
  const VirtualWearScreen({super.key});

  static const String _bodyPreviewAsset =
      'assets/images/virtual_wear/body_preview.png';
  static const String _bodyPreviewFallback =
      'https://images.unsplash.com/photo-1512316609839-ce289d3eba0a'
      '?auto=format&fit=crop&w=900&q=85';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VirtualWearProvider()..loadClothes(),
      child: const _VirtualWearView(),
    );
  }
}

class _VirtualWearView extends StatelessWidget {
  const _VirtualWearView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Transform.scale(
            scale: 1.18,
            alignment: const Alignment(0, -0.22),
            child: Image.asset(
              VirtualWearScreen._bodyPreviewAsset,
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.18),
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  VirtualWearScreen._bodyPreviewFallback,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, -0.18),
                );
              },
            ),
          ),
          Positioned.fill(
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
          Positioned.fill(
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
          const PoseDetectionOverlay(),
          const VirtualWearHeader(),
          const HoldStillBadge(),
          const ClothingSelectorPanel(),
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
        ],
      ),
    );
  }
}
