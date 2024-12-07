import 'package:flutter/material.dart';

import 'lib/components/custom_info_window.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_report_front_flutter/components/custom_info_window.dart';

void main() {
  group('CustomInfoWindow', () {
    // Test to ensure the widget displays the correct information
    testWidgets('displays the correct license plate, violation, and date',
        (WidgetTester tester) async {
      // Define the test data
      const String testLicensePlate = 'ABC123';
      const String testViolation = 'Speeding';
      const String testDate = '2024-01-16';

      // Build the CustomInfoWindow widget
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CustomInfoWindow(
            license_plate: testLicensePlate,
            violation: testViolation,
            date: testDate,
          ),
        ),
      ));

      // Verify that the CustomInfoWindow displays the correct information
      expect(find.text('车牌号: $testLicensePlate'), findsOneWidget);
      expect(find.text('违章: $testViolation'), findsOneWidget);
      expect(find.text('日期: $testDate'), findsOneWidget);
    });

    // Test to verify the styling of the CustomInfoWindow
    testWidgets('has the correct styling and layout',
        (WidgetTester tester) async {
      // Define the test data
      const String testLicensePlate = 'ABC123';
      const String testViolation = 'Speeding';
      const String testDate = '2024-01-16';

      // Build the CustomInfoWindow widget
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CustomInfoWindow(
            license_plate: testLicensePlate,
            violation: testViolation,
            date: testDate,
          ),
        ),
      ));

      // Find the CustomInfoWindow by looking for its Container widget
      final containerFinder = find.byType(Container).first;

      // Retrieve the Container widget
      final Container containerWidget =
          tester.widget(containerFinder) as Container;

      // Verify the Container's decoration
      expect(containerWidget.decoration, isNotNull);
      final BoxDecoration decoration =
          containerWidget.decoration as BoxDecoration;
      expect(decoration.color, Colors.white);
      expect(decoration.borderRadius, BorderRadius.circular(5));
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 1);
      expect(decoration.boxShadow![0].color, Colors.black26);
      expect(decoration.boxShadow![0].blurRadius, 5);
      expect(decoration.boxShadow![0].offset, const Offset(0, 2));

      // Verify padding
      expect(containerWidget.padding, const EdgeInsets.all(8));

      // Verify the layout of the texts
      final columnFinder = find.byType(Column);
      expect(columnFinder, findsOneWidget);

      final Column columnWidget = tester.widget(columnFinder) as Column;
      expect(columnWidget.mainAxisSize, MainAxisSize.min);
      expect(columnWidget.crossAxisAlignment, CrossAxisAlignment.start);

      // Verify the text styles
      final boldTextFinder = find.text('车牌号: $testLicensePlate');
      final Text boldTextWidget = tester.widget(boldTextFinder) as Text;
      expect(boldTextWidget.style, isNotNull);
      expect(boldTextWidget.style!.fontWeight, FontWeight.bold);
    });

    // Additional tests can be added here to verify other aspects of the CustomInfoWindow
  });
}
