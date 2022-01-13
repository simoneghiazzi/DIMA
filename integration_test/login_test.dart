import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sApport/Views/components/form_text_field.dart';
import 'package:sApport/Views/Home/BaseUser/components/dash_card.dart';

import 'package:sApport/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("Login procedure", () {
    testWidgets('''From the welcome page, tap on the login button and insert the email and password.
    Check that if the credentials are wrong it shows the error message, while if they are correct it brings the user to the home page.''',
        (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();

      /// Check that there is the login button
      expect(find.text("LOGIN"), findsOneWidget);

      /// Emulate a tap on the floating action button
      await tester.tap(find.widgetWithText(RoundedButton, "LOGIN"));
      await tester.pumpAndSettle();

      /// Check that there are the email and password forms and the login button
      expect(find.text("Email"), findsOneWidget);
      expect(find.text("Password"), findsOneWidget);
      expect(find.text("LOGIN"), findsOneWidget);

      /// Insert the correct email
      await tester.enterText(find.widgetWithText(FormTextField, "Email"), "user.test@sapport.it");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      /// Insert incorrect password
      await tester.enterText(find.widgetWithText(FormTextField, "Password"), "ciaociao");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      /// Emulate a tap on the floating action button.
      await tester.tap(find.widgetWithText(RoundedButton, "LOGIN"));
      await tester.pumpAndSettle();

      /// Check that the error message is shown
      expect(find.text("Wrong email or password.", findRichText: true), findsOneWidget);

      /// Insert the correct email
      await tester.enterText(find.widgetWithText(FormTextField, "Email"), "user.test@sapport.it");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      /// Insert the correct password
      await tester.enterText(find.widgetWithText(FormTextField, "Password"), "password");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      /// Emulate a tap on the floating action button.
      await tester.tap(find.widgetWithText(RoundedButton, "LOGIN"));
      await tester.pumpAndSettle();

      /// Verify that the main elements of the user's home page are found
      final gridFinder = find.byType(Table);
      final dashCardFinder = find.byType(DashCard);

      expect(gridFinder, findsOneWidget);
      expect(dashCardFinder, findsNWidgets(4));
    });
  });
}
