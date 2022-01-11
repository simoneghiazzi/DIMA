import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Model/Chat/expert_chat.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/Services/map_service.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/ViewModel/map_view_model.dart';
import 'package:sApport/Views/Chat/ChatList/chat_list_screen.dart';
import 'package:sApport/Views/Chat/ChatList/components/expert_chat_list_body.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:sApport/Views/Profile/expert_profile_screen.dart';
import 'package:sizer/sizer.dart';

import '../../navigator.mocks.dart';
import '../../view_model.mocks.dart';

void main() {
  final mockChatViewModel = MockChatViewModel();
  final mockRouterDelegate = MockAppRouterDelegate();
  final mockMapViewModel = MockMapViewModel();

  var id = Utils.randomId();
  var name = "SIMONE";
  var surname = "GHIAZZI";
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

  when(mockMapViewModel.currentExpert).thenAnswer((_) => ValueNotifier(expert));

  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(FirestoreService(FakeFirebaseFirestore()));
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService(MockFirebaseAuth()));
  getIt.registerSingleton<UserService>(UserService());
  getIt.registerSingleton<MapService>(MapService());

  group("Correct rendering: ", () {
    testWidgets("Testing the correct render of an expert's profile page", (WidgetTester tester) async {
      /// Set the physical size dimensions
      tester.binding.window.physicalSizeTestValue = Size(720, 1384);
      tester.binding.window.devicePixelRatioTestValue = 2.0;

      /// The mockNetwork is required because by default Flutter testing gives 404 as response to network requests
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider<AppRouterDelegate>(create: (_) => mockRouterDelegate),
            ChangeNotifierProvider<ChatViewModel>(create: (_) => mockChatViewModel),
            ChangeNotifierProvider<MapViewModel>(create: (_) => mockMapViewModel),
          ],
          child: Sizer(builder: (context, orientation, deviceType) {
            /// Create the expert profile screen page widget passing the expert's info
            return MaterialApp(home: ExpertProfileScreen());
          }),
        ));
      });

      final nameFinder = find.text(expert.name.toUpperCase() + " " + expert.surname.toUpperCase());
      final phoneFinder = find.text(expert.phoneNumber);
      final emailFinder = find.text(expert.email);
      final addressFinder = find.text(expert.address);

      final buttonFinder = find.text("Get In Touch");

      expect(nameFinder, findsOneWidget);
      expect(phoneFinder, findsOneWidget);
      expect(emailFinder, findsOneWidget);
      expect(addressFinder, findsOneWidget);

      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);

      /// Check replaceAllButNumber call
      var verification = verify(mockRouterDelegate.replaceAllButNumber(2, routeSettingsList: captureAnyNamed("routeSettingsList")));
      verification.called(1);

      /// Parameters Verification
      expect(verification.captured[0][0].name, ChatListScreen.route);
      expect(verification.captured[0][0].arguments, isA<ExpertChatListBody>());
      expect(verification.captured[0][1].name, ChatPageScreen.route);

      /// Check addNewChat call
      verification = verify(mockChatViewModel.addNewChat(captureAny));
      verification.called(1);

      /// Parameters Verification
      expect(verification.captured[0], isA<ExpertChat>());
      expect(verification.captured[0].peerUser, expert);
    });
  });
}
