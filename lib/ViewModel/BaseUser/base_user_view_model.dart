import 'dart:async';
import 'package:sApport/Model/BaseUser/base_user.dart';
import 'package:sApport/ViewModel/Forms/base_user_signup_form.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Model/Services/collections.dart';

class BaseUserViewModel extends UserViewModel {

  /// Load the user from the DB
  @override
  Future<void> loadLoggedUser(String id) async {
    loggedUser = BaseUser();
    return firestoreService.getUserByIdFromDB(Collection.BASE_USERS, id).then((value) => loggedUser.setFromDocument(value.docs[0]));
  }

  /// Create a new user with email and password
  @override
  BaseUser createUser(BaseUserSignUpForm baseUserSignUpForm) {
    var data = baseUserSignUpForm.values;
    loggedUser = BaseUser(name: data['name'], surname: data['surname'], birthDate: data['birthDate'], email: data['email']);
    return loggedUser;
  }
}
