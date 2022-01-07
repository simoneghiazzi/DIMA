import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class WidgetTestHelper {
  static void setPortraitDimensions(WidgetTester tester) {
    /// Set the physical size dimensions for the portrait orientation
    tester.binding.window.physicalSizeTestValue = Size(720, 1384);
    tester.binding.window.devicePixelRatioTestValue = 2.0;
  }

  static void setLandscapeDimensions(WidgetTester tester) {
    /// Set the physical size dimensions for the landscape orientation
    tester.binding.window.physicalSizeTestValue = Size(1384, 720);
    tester.binding.window.devicePixelRatioTestValue = 2.0;
  }
}
