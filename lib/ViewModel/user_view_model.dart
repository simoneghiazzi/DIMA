import 'package:dima_colombo_ghiazzi/Model/Services/firestore_service.dart';
import 'package:dima_colombo_ghiazzi/Model/user.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_info_view_model.dart';

abstract class UserViewModel {
  final FirestoreService firestore = FirestoreService();
  String id = '';
  User loggedUser;

  UserViewModel({this.id});

  /// It takes the [id] and return the logged User from the DB
  Future<User> loadLoggedUser();

  /// Create a new user with email and password with the [infoViewModel] info
  User createUser(BaseUserInfoViewModel infoViewModel);
}
