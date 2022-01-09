import 'package:mockito/annotations.dart';
import 'package:test/test.dart';
import 'package:get_it/get_it.dart';
import 'user_service_test.mocks.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';
import 'package:sApport/Views/Signup/Expert/components/form/expert_signup_form.dart';
import 'package:sApport/Views/Signup/BaseUser/components/form/base_user_signup_form.dart';
import '../../service.mocks.dart';

@GenerateMocks([BaseUserSignUpForm, ExpertSignUpForm])
void main() async {
  /// Fake Firebase
  final fakeFirebase = FakeFirebaseFirestore();

  /// Mock Services
  final mockFirebaseAuthService = MockFirebaseAuthService();
  final mockBaseUserSignUpForm = MockBaseUserSignUpForm();
  final mockExpertSignUpForm = MockExpertSignUpForm();

  /// Register Services
  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(FirestoreService(fakeFirebase));
  getIt.registerSingleton<FirebaseAuthService>(mockFirebaseAuthService);

  var loggedUser = BaseUser(
    id: Utils.randomId(),
    name: "Luca",
    surname: "Colombo",
    email: "luca.colombo@prova.it",
    birthDate: DateTime(1997, 10, 19),
  );

  var loggedExpert = Expert(
    id: Utils.randomId(),
    name: "Luca",
    surname: "Colombo",
    email: "luca.colombo@prova.it",
    birthDate: DateTime(1997, 10, 19),
    address: "Piazza Leonardo da Vinci, Milano, Italia",
    latitude: 45.478195,
    longitude: 9.2256787,
    phoneNumber: "331331331",
    profilePhoto: "Link to the profile photo",
  );

  /// Add the logged user and logged expert to the fakeFirebase
  fakeFirebase.collection(BaseUser.COLLECTION).doc(loggedUser.id).set(loggedUser.data);
  fakeFirebase.collection(Expert.COLLECTION).doc(loggedExpert.id).set(loggedExpert.data);

  /// Mock SignUp Form responses
  when(mockBaseUserSignUpForm.user).thenAnswer((_) => loggedUser);
  when(mockExpertSignUpForm.user).thenAnswer((_) => loggedExpert);

  UserService userService = UserService();

  group("UserService initialization", () {
    test("Logged user initially set to null", () {
      expect(userService.loggedUser, null);
    });
  });

  group("UserService loading base user", () {
    test("Load the signed in base user should set the logged user with the user retrieved form the Firestore DB", () async {
      /// Mock Firebase Auth Service responses
      when(mockFirebaseAuthService.currentUserId).thenAnswer((_) => loggedUser.id);

      await userService.loadLoggedUser();
      expect(userService.loggedUser, isA<BaseUser>());
    });

    test("Try to load a user with an ID that is not present into the firebase DB and check that the logged user is null", () async {
      /// Mock Firebase Auth Service responses
      when(mockFirebaseAuthService.currentUserId).thenAnswer((_) => "FAKE_ID");

      await userService.loadLoggedUser();
      expect(userService.loggedUser, null);
    });

    test("Try to load a user that is not logged in and check that the logged user is null", () async {
      /// Mock Firebase Auth Service responses
      when(mockFirebaseAuthService.currentUserId).thenAnswer((_) => null);

      await userService.loadLoggedUser();
      expect(userService.loggedUser, null);
    });

    test("Create a new logged user from the base user sign up form should set the logged user with the user created by the form", () {
      userService.createUserFromSignUpForm(mockBaseUserSignUpForm);

      expect(userService.loggedUser, isA<BaseUser>());
      expect(userService.loggedUser, loggedUser);
    });
  });

  group("UserService loading expert", () {
    test("Load the signed in expert should set the logged user with the expert retrieved form the Firestore DB", () async {
      /// Mock Firebase Auth Service responses
      when(mockFirebaseAuthService.currentUserId).thenAnswer((_) => loggedExpert.id);

      await userService.loadLoggedUser();
      expect(userService.loggedUser, isA<Expert>());
    });

    test("Create a new logged user from the expert sign up form should set the logged user with the expert created by the form", () {
      userService.createUserFromSignUpForm(mockExpertSignUpForm);

      expect(userService.loggedUser, isA<Expert>());
      expect(userService.loggedUser, loggedExpert);
    });
  });
}
