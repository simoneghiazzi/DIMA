import 'dart:async';
import 'package:sApport/Model/BaseUser/base_user.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/ViewModel/BaseUser/base_user_info_view_model.dart';

class BaseUserViewModel extends UserViewModel {
  /// Load the user from the DB
  @override
  Future<BaseUser> loadLoggedUser() async {
    if (id.isNotEmpty) {
      loggedUser = BaseUser();
      var snapshot = await firestore.getUserByIdFromDB(Collection.BASE_USERS, id);
      loggedUser.setFromDocument(snapshot.docs[0]);
      return loggedUser;
    }
    return null;
  }

  /// Create a new user with email and password
  @override
  BaseUser createUser(BaseUserInfoViewModel infoViewModel) {
    var data = infoViewModel.values;
    loggedUser = BaseUser(id: id, name: data['name'], surname: data['surname'], birthDate: data['birthDate'], email: data['email']);
    return loggedUser;
  }
}
