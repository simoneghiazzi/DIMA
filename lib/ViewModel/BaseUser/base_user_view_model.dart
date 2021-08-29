import 'dart:async';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/base_user.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_info_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/user_view_model.dart';

class BaseUserViewModel extends UserViewModel {
  BaseUserViewModel({id}) : super(id: id);

  /// It takes the [id] and load the user from the DB
  @override
  Future<BaseUser> loadLoggedUser() async {
    if (id != null) {
      loggedUser = BaseUser();
      loggedUser.setFromDocument(
          await firestore.getUserByIdFromDB(Collection.BASE_USERS, id));
      return loggedUser;
    }
    return null;
  }

  /// Create a new user with email and password
  @override
  BaseUser createUser(BaseUserInfoViewModel infoViewModel) {
    var data = infoViewModel.values;
    loggedUser = BaseUser(
        id: id,
        name: data['name'],
        surname: data['surname'],
        birthDate: data['birthDate'],
        email: data['email']);
    return loggedUser;
  }
}
