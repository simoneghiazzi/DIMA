import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sApport/Views/components/form_text_field.dart';

import 'package:sApport/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("Add a new report procedure", () {
    testWidgets('''After the login, go to the diary section and add a new diary page.
    After that, select the calendar date and check that the diary page is correctly added.''', (WidgetTester tester) async {
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

      /// Emulate a tap on the bottom navigation bar
      await tester.tap(find.byIcon(Icons.menu_book));

      /// Trigger a frame.
      await tester.pumpAndSettle();

      /// Tap the add new diary page button
      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.add));
      await tester.pumpAndSettle();

      /// Add a title
      await tester.enterText(find.widgetWithText(TextField, "What's out topic of discussion?"), "Test diary title");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      /// Add a description
      await tester.enterText(find.widgetWithText(TextField, "Tell me something about it..."), "Test diary description");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      /// Submit the diary page
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      await tester.tap(find.text("OK"));
      await tester.pumpAndSettle();

      /// Expect to find the diary page into the calendar
      expect(find.byIcon(Icons.menu_book), findsNWidgets(2));

      // /// Tap on the calendar item
      // await tester.tap(find.text("13"));
      // await tester.pumpAndSettle();

      // /// Check that the title is showed in the agenda
      // expect(find.text("Test diary title"), findsOneWidget);

      // /// Tap on the calendar item
      // await tester.tap(find.text("Test diary title"));
      // await tester.pumpAndSettle();

      // /// Check that the diary page info are showed
      // expect(find.text("Test diary title"), findsOneWidget);
      // expect(find.text("Test diary description"), findsOneWidget);
      // expect(find.byIcon(CupertinoIcons.heart), findsOneWidget);
      // expect(find.byIcon(CupertinoIcons.pencil_ellipsis_rectangle), findsOneWidget);

      // /// Try to set the diary page as favourite
      // await tester.tap(find.byIcon(CupertinoIcons.heart));
      // await tester.pumpAndSettle();
      // expect(find.byIcon(CupertinoIcons.heart_fill), findsOneWidget);
    });
  });
}
