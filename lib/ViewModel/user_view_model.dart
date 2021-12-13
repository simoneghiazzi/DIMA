import 'package:get_it/get_it.dart';
import 'package:sApport/Model/user.dart';
import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';
import 'package:sApport/ViewModel/Forms/base_user_signup_form.dart';

class UserViewModel {
  // Services
  final FirestoreService _firestoreService = GetIt.I<FirestoreService>();
  final FirebaseAuthService _firebaseAuthService = GetIt.I<FirebaseAuthService>();

  User loggedUser;

  /// It instantiate the [loggedUser] with all the retrieved information from the DB.
  ///
  /// If the user is not signed in, it throws an exception.
  Future<void> loadLoggedUser() async {
    assert(_firebaseAuthService.firebaseUser != null);
    var collection = await _firestoreService.findUserCollection(_firebaseAuthService.firebaseUser.uid);
    loggedUser = collection.userModel;
    return _firestoreService
        .getUserByIdFromDB(collection, _firebaseAuthService.firebaseUser.uid)
        .then((value) => loggedUser.setFromDocument(value.docs[0]));
  }

  /// Create a new user based on [collection] with the [baseUserSignUpForm] info.
  void createUser(Collection collection, BaseUserSignUpForm baseUserSignUpForm) {
    loggedUser = collection.userModel;
    loggedUser.setFromSignUpForm(baseUserSignUpForm);
  }
}
