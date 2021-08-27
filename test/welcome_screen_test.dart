import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Login/components/background.dart';
import 'package:dima_colombo_ghiazzi/Views/Welcome/components/welcome_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_colombo_ghiazzi/Views/Welcome/components/social_icon.dart';

void main() {
  AuthViewModel authViewModel = AuthViewModel();

  //FAI DEBUG RIGA 10 E RIGA 16 CHE SONO QUELLE TRA CUI VIENE ALZATA L'EXCEPTION
  testWidgets(
      'The welcome page has a background, a text, an image, two elevated buttons, two social icons, a gesture detector containing a text andfour sizedBoxes',
      (WidgetTester tester) async {
    await tester.pumpWidget(WelcomeBody(authViewModel: authViewModel));

    final titleFinder = find.text('APPrension');
    final expertsFinder = find.text('Are you a psychologist? Join us');
    final sizeBoxFinder = find.byType(SizedBox);
    final logoFinder = find.byType(Image);
    final backGroundFinder = find.byType(Background);
    final buttonsFinder = find.byType(ElevatedButton);
    final socialFinder = find.byType(SocialIcon);

    expect(titleFinder, findsOneWidget);
    expect(expertsFinder, findsOneWidget);
    expect(sizeBoxFinder, findsNWidgets(4));
    expect(logoFinder, findsOneWidget);
    expect(backGroundFinder, findsOneWidget);
    expect(buttonsFinder, findsNWidgets(2));
    expect(socialFinder, findsNWidgets(2));
  });
}
