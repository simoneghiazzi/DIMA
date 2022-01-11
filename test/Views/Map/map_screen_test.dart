import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Model/Map/place.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/BaseUser/Diary/diary_view_model.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/ViewModel/map_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/Map/map_screen.dart';
import 'package:sizer/sizer.dart';

import '../../Model/Services/firebase_auth_service_test.mocks.dart';
import '../../navigator.mocks.dart';
import '../../test_helper.dart';
import '../../view_model.mocks.dart';
import '../widget_test_helper.dart';

@GenerateMocks([ChatViewModel, MapViewModel, DiaryViewModel, ReportViewModel, AuthViewModel, UserViewModel])
void main() {
  final mockMapviewModel = MockMapViewModel();
  final mockRouterDelegate = MockAppRouterDelegate();

  /// Fake Firebase
  final fakeFirebase = FakeFirebaseFirestore();

  /// Register Services
  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(FirestoreService(fakeFirebase));
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService(MockFirebaseAuth()));
  getIt.registerSingleton<UserService>(UserService());

  /// Get MultiProvider Widget for creating the test
  Widget getMultiProvider({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppRouterDelegate>(create: (_) => mockRouterDelegate),
        ChangeNotifierProvider<MapViewModel>(create: (_) => mockMapviewModel),
      ],
      child: Sizer(builder: (context, orientation, deviceType) {
        return child;
      }),
    );
  }

  /// Test Helper
  final testHelper = TestHelper();

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

  var userReference = fakeFirebase.collection(expert.collection).doc(expert.id);
  userReference.set(expert.data);

  when(mockMapviewModel.selectedPlace).thenAnswer((_) => Stream<Place?>.value(null));

  when(mockMapviewModel.experts).thenAnswer((_) => testHelper.expertsLinkedHashMap);

  when(mockMapviewModel.autocompletedPlaces).thenAnswer((_) => Stream<List<Place>?>.value([]));

  final TextEditingController mockSearchTextCtrl = TextEditingController();
  when(mockMapviewModel.searchTextCtrl).thenAnswer((_) => mockSearchTextCtrl);

  group("Correct rendering:", () {
    testWidgets('Map in default position with one expert\'s pin placed', (tester) async {
      /// Set the device dimensions for the test
      WidgetTestHelper.setPortraitDimensions(tester);

      await tester.pumpWidget(getMultiProvider(child: MaterialApp(home: MapScreen())));

      final searchBarFinder = find.byType(TextField);
      final googleMapFinder = find.byType(GoogleMap);

      expect(searchBarFinder, findsOneWidget);
      expect(googleMapFinder, findsOneWidget);

      // final expertMarkerFinder = find.byType(Marker);
      // expect(expertMarkerFinder, findsOneWidget);
    });
  });
}
