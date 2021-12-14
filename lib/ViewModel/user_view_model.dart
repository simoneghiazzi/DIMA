import 'package:get_it/get_it.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/user.dart';
import 'package:sApport/ViewModel/Forms/base_user_signup_form.dart';

class UserViewModel {
  // Services
  final UserService _userService = GetIt.I<UserService>();

  /// It load the signed in user with all the retrieved information from the DB.
  ///
  /// If the user is not signed in, it throws an exception.
  Future<void> loadUser() {
    return _userService.loadLoggedUserFromDB();
  }

  /// Create a new user from the [baseUserSignUpForm] info.
  void createUser(BaseUserSignUpForm baseUserSignUpForm) {
    return _userService.createUserFromSignUpForm(baseUserSignUpForm);
  }

  /// Returns the currently logged user.
  User get loggedUser => _userService.loggedUser;
}
