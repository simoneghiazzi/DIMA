import 'package:get_it/get_it.dart';
import 'package:sApport/Model/DBItems/user.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';
import 'package:sApport/ViewModel/Forms/base_user_signup_form.dart';

/// Service that manages the [loggedUser] state inside the entire application.
class UserService {
  // Services
  final FirestoreService _firestoreService = GetIt.I<FirestoreService>();
  final FirebaseAuthService _firebaseAuthService = GetIt.I<FirebaseAuthService>();

  User loggedUser;

  /// It instantiate the [loggedUser] with all the retrieved information from the DB.
  ///
  /// If the user is not signed in, it throws an exception.
  Future<void> loadLoggedUserFromDB() async {
    assert(_firebaseAuthService.firebaseUser != null);
    loggedUser = await _firestoreService.findUserType(_firebaseAuthService.firebaseUser.uid);
    return _firestoreService
        .getUserByIdFromDB(loggedUser.collection, _firebaseAuthService.firebaseUser.uid)
        .then((value) => loggedUser.setFromDocument(value.docs[0]));
  }

  /// Create a new user from the [baseUserSignUpForm].
  void createUserFromSignUpForm(BaseUserSignUpForm baseUserSignUpForm) {
    loggedUser = baseUserSignUpForm.user;
  }
}
