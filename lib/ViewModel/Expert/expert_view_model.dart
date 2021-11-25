import 'dart:async';
import 'package:sApport/Model/Expert/expert.dart';
import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/ViewModel/BaseUser/base_user_info_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ExpertViewModel extends UserViewModel {
  /// It takes the [id] and load the user from the DB
  @override
  Future<Expert> loadLoggedUser() async {
    if (id.isNotEmpty) {
      loggedUser = Expert();
      var snapshot = await firestore.getUserByIdFromDB(Collection.EXPERTS, id);
      loggedUser.setFromDocument(snapshot.docs[0]);
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
        latLng: LatLng(data['lat'], data['lng']),
        address: data['address'],
        email: data['email'],
        phoneNumber: data['phoneNumber'],
        profilePhoto: data['profilePhoto']);
    return loggedUser;
  }
}
