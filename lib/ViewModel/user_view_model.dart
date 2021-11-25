import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/user.dart';
import 'package:sApport/ViewModel/BaseUser/base_user_info_view_model.dart';
import 'package:get_it/get_it.dart';

abstract class UserViewModel {
  final FirestoreService firestore = GetIt.I<FirestoreService>();
  String id = "";
  User loggedUser;

  /// It takes the [id] and return the logged User from the DB
  Future<User> loadLoggedUser();

  /// Create a new user with email and password with the [infoViewModel] info
  User createUser(BaseUserInfoViewModel infoViewModel);
}
