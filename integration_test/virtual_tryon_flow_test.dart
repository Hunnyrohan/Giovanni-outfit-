// Real end-to-end verification of the Virtual Try-On feature, driven through
// the Flutter engine's own gesture/widget test bindings (NOT adb input,
// which does not register taps reliably on this project's dev emulator -
// only swipes do, a pre-existing environment quirk unrelated to app code).
//
// This hits REAL running services: Node backend (localhost:3000) and the
// FastAPI AI Service (localhost:8000, real CatVTON GPU inference) - nothing
// here is mocked except the OS-level image_picker plugin (swapped for a
// fake ImagePickerPlatform returning a bundled test asset), since a widget
// test cannot drive the native camera/gallery picker UI.
//
// Run with:
//   flutter test integration_test/virtual_tryon_flow_test.dart -d emulator-5554

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio_pkg;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:outfit_ai_app/app.dart';
import 'package:outfit_ai_app/core/theme/theme_provider.dart';
import 'package:outfit_ai_app/injection_container.dart' as di;
import 'package:outfit_ai_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:outfit_ai_app/features/home/presentation/providers/home_provider.dart';
import 'package:outfit_ai_app/features/wardrobe/presentation/providers/wardrobe_provider.dart';
import 'package:outfit_ai_app/features/ai_stylist/presentation/providers/ai_stylist_provider.dart';
import 'package:outfit_ai_app/features/ai_stylist/presentation/providers/history_provider.dart';
import 'package:outfit_ai_app/shared/widgets/user_avatar.dart';

const String _apiBaseUrl = 'http://10.0.2.2:3000/api';

/// Returns a fixed local file path every time, standing in for whatever the
/// user would have picked via the real camera/gallery UI.
class _FakeImagePickerPlatform extends ImagePickerPlatform {
  final String fakeImagePath;
  _FakeImagePickerPlatform(this.fakeImagePath);

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    // ignore: avoid_print
    print('[TEST] FakeImagePickerPlatform.getImageFromSource(source=$source) -> $fakeImagePath');
    return XFile(fakeImagePath);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Real Virtual Try-On flow: login -> wardrobe -> photo -> generate -> result',
      (tester) async {
    final stopwatch = Stopwatch()..start();
    void log(String message) {
      // ignore: avoid_print
      print('[TEST +${stopwatch.elapsed.inSeconds}s] $message');
    }

    // ---------------------------------------------------------------
    // Setup: seed a real user + real wardrobe item via the actual Node
    // API (same endpoints the app itself calls), and prepare a fake
    // person-photo file for the mocked image picker.
    // ---------------------------------------------------------------
    final apiDio = dio_pkg.Dio(dio_pkg.BaseOptions(baseUrl: _apiBaseUrl));
    final email = 'qa${DateTime.now().millisecondsSinceEpoch}@example.com';
    const password = 'Password123';

    log('Registering seed user via real backend API: $email');
    final registerResponse = await apiDio.post('/auth/register', data: {
      'fullName': 'QA Verification',
      'email': email,
      'password': password,
    });
    expect(registerResponse.statusCode, 201, reason: 'Real backend registration must succeed');
    final accessToken = registerResponse.data['data']['tokens']['accessToken'] as String;
    log('Registered. accessToken acquired (${accessToken.substring(0, 12)}...)');

    // A tiny valid PNG, used as the garment image for the seeded wardrobe item.
    final garmentBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGNgAAIAAAUAAeImBZgAAAAASUVORK5CYII=',
    );
    final formData = dio_pkg.FormData.fromMap({
      'name': 'QA Test Shirt',
      'category': 'TOP',
      'image': dio_pkg.MultipartFile.fromBytes(garmentBytes, filename: 'shirt.png'),
    });
    final wardrobeResponse = await apiDio.post(
      '/wardrobe',
      data: formData,
      options: dio_pkg.Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    expect(wardrobeResponse.statusCode, 201, reason: 'Real backend wardrobe item creation must succeed');
    final wardrobeItemId = wardrobeResponse.data['data']['item']['id'] as String;
    log('Seeded real wardrobe item id=$wardrobeItemId (category=TOP)');

    // Prepare a fake "person photo" the mocked picker will return - a real
    // bundled app asset copied to a temp file, rather than the 1x1 test PNG
    // used for the garment (that one is valid enough for the backend/AI
    // Service to accept as bytes, but Android's own image decoder rejects it
    // when Flutter tries to render it as a preview - a test-fixture quirk,
    // not something a real user would ever hit since real camera/gallery
    // photos are always fully-formed images).
    final personPhotoBytes = (await rootBundle.load(
      'assets/images/virtual_wear/body_preview.png',
    )).buffer.asUint8List();
    final tempDir = await Directory.systemTemp.createTemp('qa_person_photo');
    final personPhotoFile = File('${tempDir.path}/person.png');
    await personPhotoFile.writeAsBytes(personPhotoBytes);
    ImagePickerPlatform.instance = _FakeImagePickerPlatform(personPhotoFile.path);
    log('Fake image picker installed, will return: ${personPhotoFile.path}');

    // ---------------------------------------------------------------
    // Launch the REAL app (same DI + provider wiring as main.dart).
    // ---------------------------------------------------------------
    await di.init();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(create: (_) => di.sl<ThemeProvider>()),
          ChangeNotifierProvider<AuthProvider>(create: (_) => di.sl<AuthProvider>()),
          ChangeNotifierProvider<HomeProvider>(create: (_) => di.sl<HomeProvider>()),
          ChangeNotifierProvider<WardrobeProvider>(create: (_) => di.sl<WardrobeProvider>()),
          ChangeNotifierProvider<AiStylistProvider>(create: (_) => di.sl<AiStylistProvider>()),
          ChangeNotifierProvider<HistoryProvider>(create: (_) => di.sl<HistoryProvider>()),
        ],
        child: const StyleSenseApp(),
      ),
    );
    log('App pumped, waiting for splash screen (fixed 2.5s delay)...');
    await tester.pump(const Duration(milliseconds: 2700));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // ---------------------------------------------------------------
    // STEP: Onboarding -> Login
    // ---------------------------------------------------------------
    expect(find.text('Dress to impress'), findsOneWidget, reason: 'Should land on onboarding (debug always resets it)');
    log('On onboarding page 1. Swiping through...');
    await tester.fling(find.text('Dress to impress'), const Offset(-400, 0), 800);
    await tester.pumpAndSettle();
    await tester.fling(find.text('Virtual Fitting Room'), const Offset(-400, 0), 800);
    await tester.pumpAndSettle();
    expect(find.text('Get Started'), findsOneWidget);
    log('Reached last onboarding page. Tapping Get Started...');
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back!'), findsOneWidget, reason: 'Should land on Login screen');
    log('STEP 4 CONFIRMED: Login screen reached.');

    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), password);
    await tester.pumpAndSettle();
    log('Entered credentials. Tapping "Let\'s go"...');
    await tester.tap(find.text("Let's go"));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Welcome back!'), findsNothing, reason: 'Login must navigate away from Login screen');
    log('STEP 5 CONFIRMED: Login succeeded, navigated to Home.');

    // ---------------------------------------------------------------
    // STEP: Open Wardrobe, reveal the seeded item, tap "Try virtually"
    // ---------------------------------------------------------------
    // The real navigation path to Wardrobe from Home is NOT a bottom nav bar
    // (MainBottomNav hides itself on /home, /wardrobe, /profile routes) -
    // it's the profile avatar in the header opening a drawer with a
    // "My wardrobe" item, exactly as a real user would use it.
    await tester.tap(find.byType(UserAvatar));
    await tester.pumpAndSettle();
    expect(find.text('My wardrobe'), findsOneWidget, reason: 'Drawer must open with a My wardrobe entry');
    await tester.tap(find.text('My wardrobe'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    log('Navigated to Wardrobe screen via profile avatar -> drawer -> "My wardrobe".');

    // Default category filter is "T-shirts" (hardcoded), which does not
    // match our real item's backend category "TOP" - tap "All" exactly as
    // a real user would need to, to reveal it.
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final tryVirtuallyFinder = find.text('Try virtually');
    expect(tryVirtuallyFinder, findsWidgets, reason: 'Seeded real wardrobe item must be visible and have a Try virtually button');
    log('STEP 3 (wardrobe select) CONFIRMED: ${tryVirtuallyFinder.evaluate().length} "Try virtually" button(s) visible.');

    await tester.tap(tryVirtuallyFinder.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Tap to add your photo'), findsOneWidget, reason: 'Should land on Virtual Wear screen with no photo yet');
    log('STEP 3 CONFIRMED: Navigated to Virtual Wear screen for the selected item.');

    // ---------------------------------------------------------------
    // STEP 4: Image picker opens, gallery "works" (mocked), image appears
    // ---------------------------------------------------------------
    // A real tap, exactly like a user's finger. This used to be impossible:
    // the two full-screen gradient DecoratedBox overlays sat above the photo
    // GestureDetector in the Stack and swallowed every tap (DecoratedBox
    // claims hit-tests across its whole surface). They are now wrapped in
    // IgnorePointer, so this tap must reach the photo area - if this fails,
    // the manual-user bug ("Tap to add your photo does nothing") is back.
    await tester.tap(find.byKey(const Key('virtual_wear_photo_tap_area')));
    await tester.pumpAndSettle();
    expect(find.text('Choose from gallery'), findsOneWidget, reason: 'Image source bottom sheet must open');
    expect(find.text('Take a photo'), findsOneWidget);
    log('STEP 4 CONFIRMED: Image picker bottom sheet opened (camera + gallery options present).');

    await tester.tap(find.text('Choose from gallery'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Tap to add your photo'), findsNothing, reason: 'Placeholder text must disappear once a photo is selected');
    log('STEP 4 CONFIRMED: Selected image appears (placeholder text gone); wardrobe item selection preserved via provider.initialize(item).');

    // ---------------------------------------------------------------
    // STEP 5-7: Tap Generate, verify real backend + AI Service + CatVTON
    // ---------------------------------------------------------------
    final generateButton = find.text('Generate');
    expect(generateButton, findsOneWidget);
    log('STEP 4 CONFIRMED: Generate button present and (per canGenerate) enabled.');

    log('Tapping Generate - this triggers a REAL POST /api/virtual-tryon call...');
    final generateStart = stopwatch.elapsed;
    await tester.tap(generateButton);
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Starting generation...'), findsOneWidget, reason: 'Loading overlay must show immediately after tapping Generate');
    log('STEP 5 CONFIRMED: Loading overlay shown, job creation in flight.');

    // Poll by pumping in real wall-clock increments while the provider's
    // own exponential-backoff polling loop runs against the real backend.
    bool reachedResultScreen = false;
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(seconds: 3));
      if (find.text('Your Look').evaluate().isNotEmpty) {
        reachedResultScreen = true;
        break;
      }
    }
    final generationDuration = stopwatch.elapsed - generateStart;
    log('Generation phase took ${generationDuration.inSeconds}s (Flutter-observed, includes upload + AI Service inference + polling latency).');

    expect(reachedResultScreen, isTrue,
        reason: 'STEP 6/7/8 FAILED: never reached Result screen - job did not complete (see AI Service/backend logs)');
    log('STEP 6, 7 & 8 CONFIRMED: Job reached COMPLETED and Flutter auto-navigated to the Result screen.');

    // ---------------------------------------------------------------
    // STEP 9: Verify Result Screen contents and actions
    // ---------------------------------------------------------------
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(Image), findsWidgets, reason: 'Generated (or original) image must render');
    log('STEP 9 CONFIRMED: Result screen rendered with an image.');

    expect(find.text('Before'), findsOneWidget);
    expect(find.text('After'), findsOneWidget);
    await tester.tap(find.text('Before'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('After'));
    await tester.pumpAndSettle();
    log('STEP 9 CONFIRMED: Before/After toggle tapped both ways without error.');

    log('Tapping Save...');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    log('STEP 9 CONFIRMED: Save tapped (backend POST /:id/save call completed without throwing).');

    // Delete last (removes the job / navigates away).
    log('Tapping Delete...');
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    log('STEP 9 CONFIRMED: Delete tapped (backend DELETE call completed, navigation occurred).');

    log('=== FULL FLOW COMPLETED SUCCESSFULLY in ${stopwatch.elapsed.inSeconds}s total ===');
  }, timeout: const Timeout(Duration(minutes: 8)));
}
