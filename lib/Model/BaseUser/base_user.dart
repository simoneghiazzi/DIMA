import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/user.dart';
import 'package:sApport/Views/Home/BaseUser/base_user_home_page_screen.dart';

class BaseUser extends User {
  static const COLLECTION = "users";
  static const HOMEPAGE_ROUTE = BaseUserHomePageScreen.route;

  BaseUser({String id, String name, String surname, DateTime birthDate, String email})
      : super(COLLECTION, HOMEPAGE_ROUTE, id: id, name: name, surname: surname, birthDate: birthDate, email: email);

  @override
  void setFromDocument(DocumentSnapshot doc) {
    try {
      id = doc.id;
      name = doc.get("name");
      surname = doc.get("surname");
      birthDate = doc.get("birthDate").toDate();
      email = doc.get("email");
    } catch (e) {
      print("Error in setting the base user from the document snapshot: $e");
    }
  }

  @override
  Map<String, Object> get data {
    return {
      "uid": id,
      "name": name,
      "surname": surname,
      "birthDate": birthDate,
      "email": email,
    };
  }
}
