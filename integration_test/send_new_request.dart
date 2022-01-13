import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sApport/Views/Home/BaseUser/components/dash_card.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sApport/Views/components/form_text_field.dart';

import 'package:sApport/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("Add a new report procedure", () {
    testWidgets('''After the login, go to anonymous chats, look for a new random user and send a new message''', (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();

      /// Login
      await tester.tap(find.widgetWithText(RoundedButton, "LOGIN"));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(FormTextField, "Email"), "user.test@sapport.it");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.enterText(find.widgetWithText(FormTextField, "Password"), "password");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.tap(find.widgetWithText(RoundedButton, "LOGIN"));
      await tester.pumpAndSettle();

      /// Emulate a tap on the floating action button.
      await tester.tap(find.widgetWithText(DashCard, "Anonymous\nchats"));

      /// Trigger a frame.
      await tester.pumpAndSettle();

      /// Tap the add new diary page button
      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.add));
      await tester.pumpAndSettle();

      /// Send a message
      await tester.enterText(find.widgetWithText(TextField, "Type your message..."), "Test new message");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      /// Check that the message appears
      expect(find.text("Test new message"), findsOneWidget);
    });
  });
}
