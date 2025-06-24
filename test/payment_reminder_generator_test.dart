import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:interest_book/Utils/payment_reminder_generator.dart';

void main() {
  group('PaymentReminderGenerator Tests', () {
    testWidgets('PaymentReminderWidget should render correctly', (WidgetTester tester) async {
      // Create the widget
      const widget = PaymentReminderWidget(
        customerName: 'John Doe',
        totalAmount: 5000.0,
        companyName: 'Test Company',
        customMessage: 'Test payment reminder message',
      );

      // Build the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: widget,
          ),
        ),
      );

      // Verify that the widget renders without errors
      expect(find.text('Test Company'), findsOneWidget);
      expect(find.text('PAYMENT REMINDER'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Test payment reminder message'), findsOneWidget);
      expect(find.text('Verified by Test Company'), findsOneWidget);
    });

    test('PaymentReminderGenerator should handle null custom message', () async {
      // This test verifies that the generator can handle null custom message
      const widget = PaymentReminderWidget(
        customerName: 'Jane Smith',
        totalAmount: 3000.0,
        companyName: 'Another Company',
        customMessage: null,
      );

      // The widget should be created without errors
      expect(widget.customerName, equals('Jane Smith'));
      expect(widget.totalAmount, equals(3000.0));
      expect(widget.companyName, equals('Another Company'));
      expect(widget.customMessage, isNull);
    });
  });
}
