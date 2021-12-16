import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/DBItems/user.dart';
import 'package:sApport/Views/Home/Expert/expert_home_page_screen.dart';

class Expert extends User {
  static const COLLECTION = "experts";
  static const HOMEPAGE_ROUTE = ExpertHomePageScreen.route;

  String address;
  String phoneNumber;
  String profilePhoto;
  double latitude;
  double longitude;

  Expert({
    String id,
    String name,
    String surname,
    DateTime birthDate,
    String email,
    this.latitude,
    this.longitude,
    this.address,
    this.phoneNumber,
    this.profilePhoto,
  }) : super(COLLECTION, HOMEPAGE_ROUTE, id: id, name: name, surname: surname, birthDate: birthDate, email: email);

  /// Create an instance of the [Expert] form the [doc] fields retrieved from the FireBase DB.
  factory Expert.fromDocument(DocumentSnapshot doc) {
    try {
      return Expert(
        id: doc.id,
        name: doc.get("name"),
        surname: doc.get("surname"),
        birthDate: doc.get("birthDate").toDate(),
        latitude: doc.get("lat"),
        longitude: doc.get("lng"),
        address: doc.get("address"),
        email: doc.get("email"),
        phoneNumber: doc.get("phoneNumber"),
        profilePhoto: doc.get("profilePhoto"),
      );
    } catch (e) {
      print("Error in creating the expert from the document snapshot: $e");
      return null;
    }
  }

  @override
  void setFromDocument(DocumentSnapshot doc) {
    try {
      id = doc.id;
      name = doc.get("name");
      surname = doc.get("surname");
      birthDate = doc.get("birthDate").toDate();
      latitude = doc.get("lat");
      longitude = doc.get("lng");
      address = doc.get("address");
      email = doc.get("email");
      phoneNumber = doc.get("phoneNumber");
      profilePhoto = doc.get("profilePhoto");
    } catch (e) {
      print("Error in setting the message from the document snapshot: $e");
    }
  }

  @override
  Map<String, Object> get data {
    return {
      "eid": id,
      "name": name,
      "surname": surname,
      "birthDate": birthDate,
      "address": address,
      "lat": latitude,
      "lng": longitude,
      "phoneNumber": phoneNumber,
      "email": email,
      "profilePhoto": profilePhoto,
    };
  }
}
