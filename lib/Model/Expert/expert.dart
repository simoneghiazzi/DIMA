import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/user.dart';
import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/ViewModel/Forms/base_user_signup_form.dart';

class Expert extends User {
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
  }) : super(id: id, name: name, surname: surname, birthDate: birthDate, email: email);

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
      print("Error in setting the expert from the document snapshot: $e");
    }
  }

  @override
  void setFromSignUpForm(BaseUserSignUpForm experSignUpForm) {
    try {
      name = experSignUpForm.data["name"];
      surname = experSignUpForm.data["surname"];
      birthDate = experSignUpForm.data["birthDate"];
      email = experSignUpForm.data["email"];
      latitude = experSignUpForm.data["lat"];
      longitude = experSignUpForm.data["lng"];
      address = experSignUpForm.data["address"];
      phoneNumber = experSignUpForm.data["phoneNumber"];
      profilePhoto = experSignUpForm.data["profilePhoto"];
    } catch (e) {
      print("Error in setting the expert from the expert signup form: $e");
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

  @override
  Collection get collection => Collection.EXPERTS;
}
