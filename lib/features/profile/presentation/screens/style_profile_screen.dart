import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/style_profile_provider.dart';
import '../widgets/last_outfit_list.dart';
import '../widgets/profile_add_collection_button.dart';
import '../widgets/profile_avatar_large.dart';
import '../widgets/profile_bottom_nav.dart';
import '../widgets/profile_collection_section.dart';
import '../widgets/style_profile_header.dart';

class StyleProfileScreen extends StatelessWidget {
  const StyleProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StyleProfileProvider(),
      child: const _StyleProfileView(),
    );
  }
}

class _StyleProfileView extends StatelessWidget {
  const _StyleProfileView();

  static const double _designWidth = 351;
  static const double _designHeight = 768;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StyleProfileProvider>();

    return Scaffold(
      backgroundColor: const Color(0xff050505),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final widthScale = constraints.maxWidth / _designWidth;
          final heightScale = constraints.maxHeight / _designHeight;
          final scale = widthScale < heightScale ? widthScale : heightScale;

          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: _designWidth * scale,
              height: _designHeight * scale,
              child: FittedBox(
                fit: BoxFit.fill,
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: _designWidth,
                  height: _designHeight,
                  child: provider.isLoading
                      ? const ColoredBox(color: Color(0xff050505))
                      : Stack(
                          children: [
                            const Positioned.fill(
                              child: ColoredBox(color: Color(0xff050505)),
                            ),
                            const Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: _ProfileTopCurve(),
                            ),
                            const Positioned(
                              top: 40,
                              left: 25,
                              child: StyleProfileHeader(),
                            ),
                            Positioned(
                              top: 71,
                              left: 0,
                              right: 0,
                              child: ProfileAvatarLarge(
                                imageUrl: provider.profile.avatarImage,
                                name: provider.profile.name,
                              ),
                            ),
                            Positioned(
                              top: 237,
                              left: 21,
                              width: 296,
                              child: LastOutfitList(
                                outfits: provider.lastOutfits,
                              ),
                            ),
                            Positioned(
                              top: 523,
                              left: 21,
                              width: 296,
                              child: ProfileCollectionSection(
                                collections: provider.collections,
                                collectionCount:
                                    provider.profile.collectionCount,
                                likesCount: provider.profile.likesCount,
                              ),
                            ),
                            const Positioned(
                              top: 603,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: ProfileAddCollectionButton(),
                              ),
                            ),
                            const Positioned(
                              top: 674,
                              left: 0,
                              right: 0,
                              child: Center(child: ProfileBottomNav()),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileTopCurve extends StatelessWidget {
  const _ProfileTopCurve();

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _ProfileTopCurveClipper(),
      child: Container(
        width: 351,
        height: 145,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xffd66868),
              Color(0xffb1a5a5),
              Color(0xffa9a9a9),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, 82)
      ..quadraticBezierTo(size.width / 2, 164, size.width, 84)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _ProfileTopCurveClipper oldClipper) => false;
}
