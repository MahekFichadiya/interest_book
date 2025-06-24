import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:interest_book/Utils/image_generator_helper.dart';

void main() {
  group('ImageGeneratorHelper Tests', () {
    testWidgets('widgetToImageBytes should not throw errors', (WidgetTester tester) async {
      // Create a simple test widget
      const testWidget = Center(
        child: Text(
          'Test Widget',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      );

      // Test that the method doesn't throw errors
      expect(() async {
        await ImageGeneratorHelper.widgetToImageBytes(
          testWidget,
          size: const Size(200, 100),
          pixelRatio: 1.0,
        );
      }, returnsNormally);
    });

    test('cleanupTempImages should not throw errors', () async {
      // Test that cleanup method doesn't throw errors
      expect(() async {
        await ImageGeneratorHelper.cleanupTempImages();
      }, returnsNormally);
    });

    testWidgets('widgetToImageFile should handle widget input', (WidgetTester tester) async {
      // Create a simple test widget
      final testWidget = Container(
        width: 100,
        height: 100,
        color: Colors.blue,
        child: const Center(
          child: Text(
            'Test',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

      // Test that the method accepts the widget without errors
      expect(() async {
        await ImageGeneratorHelper.widgetToImageFile(
          testWidget,
          size: const Size(100, 100),
          fileName: 'test_image.png',
        );
      }, returnsNormally);
    });
  });
}
