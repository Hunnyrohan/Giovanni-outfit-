// This is a basic Flutter widget test for StyleSense AI.
import 'package:flutter_test/flutter_test.dart';
import 'package:outfit_ai_app/app.dart';
import 'package:outfit_ai_app/injection_container.dart' as di;
import 'package:provider/provider.dart';
import 'package:outfit_ai_app/features/auth/presentation/providers/auth_provider.dart';

void main() {
  testWidgets('App splash screen smoke test', (WidgetTester tester) async {
    // Initialize dependency injection locator
    await di.init();
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => di.sl<AuthProvider>(),
          ),
        ],
        child: const StyleSenseApp(),
      ),
    );

    // Verify that our Splash Screen renders the App Name
    expect(find.text('Giovanni'), findsOneWidget);
    expect(find.text('Personal AI stylist'), findsOneWidget);
  });
}
