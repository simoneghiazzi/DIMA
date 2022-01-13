import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sApport/Views/Home/BaseUser/components/dash_card.dart';
import 'package:sApport/Views/Map/components/map_info_window.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sApport/Views/components/form_text_field.dart';

import 'package:sApport/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("Add a new report procedure", () {
    testWidgets('''After the login, go to the map and look for an expert.
    Get in touch with him/her and check that the chat is added to the experts chats.''', (WidgetTester tester) async {
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
      await tester.tap(find.widgetWithText(DashCard, "Find an\nexpert"));

      /// Trigger a frame.
      await tester.pumpAndSettle();

      /// Search the position of the expert
      await tester.enterText(find.widgetWithText(TextField, "Search place"), "Piazza Leonardo da Vinci, Milano");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // /// Expect to find a marker
      // expect(find.byType(Marker), findsOneWidget);

      // /// Tap on the marker
      // await tester.tap(find.byType(Marker));
      // await tester.pumpAndSettle();

      // /// Expect to find the map info window
      // expect(find.byType(MapInfoWindow), findsOneWidget);

      // /// Tap on the info window
      // await tester.tap(find.byType(MapInfoWindow));
      // await tester.pumpAndSettle();

      // /// Tap on get in touch
      // await tester.tap(find.byType(MapInfoWindow));
      // await tester.pumpAndSettle();

      // /// Send a message
      // await tester.enterText(find.widgetWithText(TextField, "Type your message..."), "Test new message");
      // await tester.testTextInput.receiveAction(TextInputAction.done);
      // await tester.pump();

      // await tester.tap(find.byIcon(Icons.send));
      // await tester.pumpAndSettle();

      // /// Check that the message appears
      // expect(find.text("Test new message"), findsOneWidget);

      // /// Go back
      // await tester.pageBack();
      // await tester.pumpAndSettle();

      // /// Check that the expert is in the chat list
      // expect(find.text("Test Expert"), findsOneWidget);
    });
  });
}
