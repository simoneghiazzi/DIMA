import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_test/flutter_test.dart' as tester;

void main() {
  final orDividerFinder = find.byValueKey('or_divider');

  FlutterDriver driver;

  tester.setUpAll(() async {
    driver = await FlutterDriver.connect();
  });

  // Close the connection to the driver after the tests have completed.
  tester.tearDownAll(() async {
    driver.close();
  });

  tester.test('one or divider', () async {
    tester.expect(await driver.waitFor(tester.find.byKey('or_divider')),
        tester.findsOneWidget);
  });
}
