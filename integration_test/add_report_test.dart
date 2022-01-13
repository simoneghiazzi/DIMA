import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sApport/Views/components/form_text_field.dart';
import 'package:sApport/Views/Home/BaseUser/components/dash_card.dart';

import 'package:sApport/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("Add a new report procedure", () {
    testWidgets('''After the login, go to the report section and add a new report.
    After that, go to the report list and check that the report is correctly added.''', (WidgetTester tester) async {
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
      await tester.tap(find.widgetWithText(DashCard, "Anonymous\nreports"));

      /// Trigger a frame.
      await tester.pumpAndSettle();

      /// Select the report category
      await tester.tap(find.text("Report category"), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text("Psychological violence").last);
      await tester.pumpAndSettle();

      /// Add a text description
      await tester.enterText(find.widgetWithText(TextFieldBlocBuilder, "Report description"), "Test report description");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      /// Submit the report page
      await tester.tap(find.text("SUBMIT"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("OK"));
      await tester.pumpAndSettle();

      /// Expect to find the report into the report list
      expect(find.text("Psychological violence"), findsOneWidget);

      /// Tap on the report item
      await tester.tap(find.text("Psychological violence").last);
      await tester.pumpAndSettle();

      /// Check that the report information are correct
      expect(find.text("Psychological violence"), findsOneWidget);
      expect(find.text("Test report description"), findsOneWidget);
    });
  });
}
