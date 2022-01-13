import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sApport/Views/components/form_text_field.dart';

import 'package:sApport/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("SignUp procedure", () {
    testWidgets('''From the welcome page, tap on the signUp button and add the correct information of the user. 
        Then in the credential page add the email and password and complete the signUp procedure.''', (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();

      /// Check that there is the login button
      expect(find.text("SIGNUP"), findsOneWidget);

      /// Finds the floating action button to tap on
      Finder signUp = find.widgetWithText(RoundedButton, "SIGNUP");

      /// Emulate a tap on the floating action button
      await tester.tap(signUp);

      /// Trigger a frame
      await tester.pumpAndSettle();

      /// Check that there is the email form
      expect(find.text("First name"), findsOneWidget);
      expect(find.text("Last name"), findsOneWidget);
      expect(find.text("Birth date"), findsOneWidget);

      /// Insert the name
      await tester.enterText(find.widgetWithText(FormTextField, "First name"), "User");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      /// Insert the surname
      await tester.enterText(find.widgetWithText(FormTextField, "Last name"), "Test");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      /// Insert the birth date
      await tester.tap(find.widgetWithText(DateTimeFieldBlocBuilder, "Birth date"));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), "5/15/1997");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      await tester.tap(find.text("OK"));
      await tester.pumpAndSettle();

      /// Finds the floating action button to tap on.
      await tester.tap(find.widgetWithText(RoundedButton, "NEXT"));
      await tester.pumpAndSettle();

      /// Check that there are the email and password forms
      expect(find.text("Email"), findsOneWidget);
      expect(find.text("Password"), findsOneWidget);
      expect(find.text("Confirm Password"), findsOneWidget);
      await tester.pump();

      await tester.enterText(find.widgetWithText(FormTextField, "Email"), "user.test@sApport.it");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      await tester.enterText(find.widgetWithText(FormTextField, "Password"), "password");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      await tester.enterText(find.widgetWithText(FormTextField, "Confirm Password"), "password");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      await tester.tap(find.widgetWithText(RoundedButton, "SIGNUP"));
      await tester.pumpAndSettle();

      /// Check that there are the email and password forms
      expect(find.text("Email"), findsOneWidget);
      expect(find.text("Password"), findsOneWidget);

      /// Check that there is the LOGIN button
      expect(find.text("LOGIN"), findsOneWidget);

      /// Check that there is the SnackBar with the 'email verification sent' message
      expect(find.widgetWithText(SnackBar, "Please check your email for the verification link."), findsOneWidget);
    });
  });
}
