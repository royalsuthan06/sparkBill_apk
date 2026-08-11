import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sparkbill/main.dart';
import 'package:sparkbill/providers/pos_provider.dart';

void main() {
  testWidgets('Smoke test - app loads without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => POSProvider(),
        child: const SparkBillPOSApp(),
      ),
    );

    // Verify if our navigation matches key components
    expect(find.byType(SparkBillPOSApp), findsOneWidget);
  });
}
