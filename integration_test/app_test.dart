import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sheba_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('should navigate through main app flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Check if home screen is displayed
      expect(find.text('استعلام اطلاعات بانکی'), findsOneWidget);

      // Check if tabs are present
      expect(find.text('کارت به شبا'), findsOneWidget);
      expect(find.text('حساب به شبا'), findsOneWidget);
      expect(find.text('اطلاعات شبا'), findsOneWidget);

      // Test navigation to history screen
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      // Go back to home
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Test navigation to batch inquiry screen
      await tester.tap(find.byIcon(Icons.upload_file));
      await tester.pumpAndSettle();

      expect(find.text('استعلام گروهی'), findsOneWidget);
    });

    testWidgets('should handle card input validation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find the card input field
      final cardInputField = find.byType(TextFormField).first;
      
      // Test empty input validation
      await tester.tap(find.text('استعلام'));
      await tester.pumpAndSettle();
      
      // Should show validation error
      expect(find.text('لطفاً شماره کارت را وارد کنید'), findsOneWidget);

      // Test invalid card number
      await tester.enterText(cardInputField, '123');
      await tester.tap(find.text('استعلام'));
      await tester.pumpAndSettle();
      
      // Should show validation error
      expect(find.text('شماره کارت باید 16 رقم باشد'), findsOneWidget);
    });

    testWidgets('should switch between tabs correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test switching to account to sheba tab
      await tester.tap(find.text('حساب به شبا'));
      await tester.pumpAndSettle();

      expect(find.text('استعلام شبا با شماره حساب'), findsOneWidget);

      // Test switching to sheba info tab
      await tester.tap(find.text('اطلاعات شبا'));
      await tester.pumpAndSettle();

      expect(find.text('استعلام اطلاعات شبا'), findsOneWidget);

      // Switch back to card to sheba tab
      await tester.tap(find.text('کارت به شبا'));
      await tester.pumpAndSettle();

      expect(find.text('استعلام شبا با شماره کارت'), findsOneWidget);
    });

    testWidgets('should handle batch inquiry file selection', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to batch inquiry screen
      await tester.tap(find.byIcon(Icons.upload_file));
      await tester.pumpAndSettle();

      // Check if file selection button is present
      expect(find.text('انتخاب فایل اکسل'), findsOneWidget);
      expect(find.text('فایل اکسل حاوی شماره کارت‌ها'), findsOneWidget);
    });
  });
}

