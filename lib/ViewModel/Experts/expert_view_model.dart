import 'dart:async';
import 'package:dima_colombo_ghiazzi/Model/Expert/expert.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_info_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/user_view_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ExpertViewModel extends UserViewModel {
  ExpertViewModel({id}) : super(id: id);

  /// It takes the [id] and load the user from the DB
  @override
  Future<Expert> loadLoggedUser() async {
    if (id.isNotEmpty) {
      loggedUser = Expert();
      loggedUser.setFromDocument(
          await firestore.getUserByIdFromDB(Collection.EXPERTS, id));
      return loggedUser;
    }
    return null;
  }

  /// Create a new user with email and password
  @override
  Expert createUser(BaseUserInfoViewModel infoViewModel) {
    var data = infoViewModel.values;
    loggedUser = Expert(
        id: id,
        name: data['name'],
        surname: data['surname'],
        birthDate: data['birthDate'],
        address: LatLng(data['lat'], data['lng']),
        phoneNumber: data['phoneNumber'],
        profilePhoto: data['profilePhoto']);
    return loggedUser;
  }
}
