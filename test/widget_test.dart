import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecotrack/main.dart';

void main() {
  testWidgets('Splash Screen displays App Title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: EcoTrackApp(),
      ),
    );

    // Verify that our app builds and shows 'ECOTRACK' logo text
    expect(find.text('ECOTRACK'), findsOneWidget);

    // Pump the timeline by 3.6 seconds to let the splash timers complete, 
    // trigger the route navigation, and dispose the splash screen (cancelling periodic timers).
    await tester.pump(const Duration(milliseconds: 3600));
  });
}
