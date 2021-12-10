import 'package:get_it/get_it.dart';
import 'package:sApport/Model/user.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/ViewModel/Forms/base_user_signup_form.dart';

abstract class UserViewModel {
  final FirestoreService firestoreService = GetIt.I<FirestoreService>();
  User loggedUser;
  
  /// It takes the [id] and return the logged User from the DB
  Future<void> loadLoggedUser(String id);

  /// Create a new user with email and password with the [infoViewModel] info
  User createUser(BaseUserSignUpForm infoViewModel);
}
