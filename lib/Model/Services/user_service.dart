import 'package:get_it/get_it.dart';
import 'package:sApport/Model/DBItems/user.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';
import 'package:sApport/Views/Signup/BaseUser/components/form/base_user_signup_form.dart';

/// Service that manages the [loggedUser] state inside the entire application.
class UserService {
  // Services
  final FirestoreService _firestoreService = GetIt.I<FirestoreService>();
  final FirebaseAuthService _firebaseAuthService = GetIt.I<FirebaseAuthService>();

  User? loggedUser;

  /// It instantiate the [loggedUser] with all the retrieved information from the DB.
  ///
  /// If the user is not signed in, it throws an exception.
  Future<void> loadLoggedUserFromDB() async {
    if (_firebaseAuthService.currentUserId != null) {
      loggedUser = await _firestoreService.findUserType(_firebaseAuthService.currentUserId!);
      if (loggedUser != null) {
        return _firestoreService
            .getUserByIdFromDB(loggedUser!.collection, _firebaseAuthService.currentUserId!)
            .then((value) => loggedUser!.setFromDocument(value.docs[0]))
            .catchError((error) => print("Error in getting the user from DB: $error"));
      }
    }
  }

  /// Create a new user from the [baseUserSignUpForm].
  void createUserFromSignUpForm(BaseUserSignUpForm baseUserSignUpForm) {
    loggedUser = baseUserSignUpForm.user;
  }
}
