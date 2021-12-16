import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Profile/expert_profile_screen.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  final fakeFirebase = FakeFirebaseFirestore();
  FirestoreService _firestoreService = FirestoreService(fakeFirebase);

  var id = Utils.randomId();
  var name = "Simone";
  var surname = "Ghiazzi";
  var email = "simone.ghiazzi@prova.it";
  var birthDate = DateTime(1997, 10, 19);
  var latitude = 100.0;
  var longitude = 300.5;
  var address = "Piazza Leonardo da Vinci, 32, Milan, Province of Milan, Italia";
  var phoneNumber = "3333333333";
  var profilePhoto = "https://example.com/image.png";

  Expert expert = Expert(
    id: id,
    name: name,
    surname: surname,
    email: email,
    birthDate: birthDate,
    latitude: latitude,
    longitude: longitude,
    address: address,
    phoneNumber: phoneNumber,
    profilePhoto: profilePhoto,
  );

  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(FirestoreService(FakeFirebaseFirestore()));
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService(MockFirebaseAuth()));
  getIt.registerSingleton<UserService>(UserService());

  AppRouterDelegate routerDelegate = AppRouterDelegate();

  testWidgets("Testing the correct render of an expert's profile page", (WidgetTester tester) async {
    //Create the expert profile screen page widget passing the expert's info
    Widget testWidget = new MediaQuery(
      data: new MediaQueryData(),
      child: new MaterialApp(home: new ExpertProfileScreen(expert: expert)),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppRouterDelegate>(create: (_) => routerDelegate),
          ChangeNotifierProvider<ChatViewModel>(create: (_) => ChatViewModel()),
        ],
        child: Builder(
          builder: (_) => testWidget,
        ),
      ),
    );

    // final imageFinder =
    final nameFinder = find.text(expert.name.toUpperCase() + " " + expert.surname.toUpperCase());
    final phoneFinder = find.text(expert.phoneNumber);

    expect(nameFinder, findsOneWidget);
    expect(phoneFinder, findsOneWidget);
  });
}
