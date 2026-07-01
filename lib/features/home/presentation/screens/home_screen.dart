import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/app_custom_drawer.dart';
import '../widgets/ai_search_bar.dart';
import '../widgets/ai_title_section.dart';
import '../widgets/category_chip_list.dart';
import '../widgets/floating_home_nav.dart';
import '../widgets/home_header.dart';
import '../widgets/outfit_carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _designWidth = 430;
  static const double _designHeight = 932;
  static const double _referenceScale = 430 / 310;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedCategory = 'Office';

  @override
  void reassemble() {
    super.reassemble();
    _selectedCategory = 'Office';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppCustomDrawer(),
      drawerScrimColor: Colors.black.withValues(alpha: 0.45),
      backgroundColor: const Color(0xff101010),
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
                  child: Transform.scale(
                    scale: _referenceScale,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 310,
                      height: 673,
                      child: Stack(
                        children: [
                          const Positioned.fill(child: _HomeBackground()),
                          Positioned(
                            top: 30,
                            left: 15,
                            width: 273,
                            child: HomeHeader(
                              onProfileTap: () =>
                                  _scaffoldKey.currentState?.openDrawer(),
                            ),
                          ),
                          const Positioned(
                            top: 109,
                            left: 15,
                            right: 15,
                            child: AiTitleSection(),
                          ),
                          const Positioned(
                            top: 162,
                            left: 15,
                            width: 273,
                            child: AiSearchBar(),
                          ),
                          Positioned(
                            top: 231,
                            left: 15,
                            child: Text(
                              'Recommended for you',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12.8,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 259,
                            left: 0,
                            right: 0,
                            child: CategoryChipList(
                              selectedCategory: _selectedCategory,
                              onSelected: (category) {
                                setState(() => _selectedCategory = category);
                              },
                            ),
                          ),
                          Positioned(
                            top: 317,
                            left: 0,
                            right: 0,
                            child: OutfitCarousel(category: _selectedCategory),
                          ),
                          Positioned(
                            top: 556,
                            left: 61,
                            child: const FloatingHomeNav(),
                          ),
                        ],
                      ),
                    ),
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

class _HomeBackground extends StatelessWidget {
  const _HomeBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xff0d0d0d),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.centerLeft,
          colors: [
            const Color(0xff342527).withValues(alpha: 0.82),
            const Color(0xff111111),
            const Color(0xff0b0b0b),
          ],
          stops: const [0, 0.42, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -84,
            top: 300,
            width: 180,
            height: 138,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xff7f743f).withValues(alpha: 0.48),
                    const Color(0xff0d0d0d).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -70,
            bottom: -18,
            width: 190,
            height: 180,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xff7a4d75).withValues(alpha: 0.58),
                    const Color(0xff0d0d0d).withValues(alpha: 0),
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
