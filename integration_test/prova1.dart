import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sApport/Views/Home/BaseUser/components/dash_card.dart';
import 'package:sApport/Views/components/form_text_field.dart';
import 'package:sApport/Views/components/rounded_button.dart';

import 'package:sApport/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("Login procedure", () {
    testWidgets("From the welcome page, tap on the login button and insert the email and password", (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();

      /// Check that there is the login button
      expect(find.text("LOGIN"), findsOneWidget);

      /// Finds the floating action button to tap on.
      Finder login = find.widgetWithText(RoundedButton, "LOGIN");

      /// Emulate a tap on the floating action button.
      await tester.tap(login);

      /// Trigger a frame.
      await tester.pumpAndSettle();

      /// Check that there is the email form
      expect(find.text("Email"), findsOneWidget);
      expect(find.text("Password"), findsOneWidget);

      await tester.enterText(find.widgetWithText(FormTextField, "Email"), "luca.colombo97@libero.it");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      /// Insert the correct password
      await tester.enterText(find.widgetWithText(FormTextField, "Password"), "ciaociao");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      /// Finds the floating action button to tap on.
      login = find.widgetWithText(RoundedButton, "LOGIN");

      /// Emulate a tap on the floating action button.
      await tester.tap(login);

      /// Trigger a frame.
      await tester.pumpAndSettle();

      expect(find.byType(DashCard), findsNWidgets(4));
    });
  });
}
