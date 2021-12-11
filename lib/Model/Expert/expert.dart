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
    } catch (e) {}
    try {
      name = doc.get("name");
    } catch (e) {}
    try {
      surname = doc.get("surname");
    } catch (e) {}
    try {
      birthDate = doc.get("birthDate");
    } catch (e) {}
    try {
      latitude = doc.get("lat");
    } catch (e) {}
    try {
      longitude = doc.get("lng");
    } catch (e) {}
    try {
      address = doc.get("address");
    } catch (e) {}
    try {
      email = doc.get("email");
    } catch (e) {}
    try {
      phoneNumber = doc.get("phoneNumber");
    } catch (e) {}
    try {
      profilePhoto = doc.get("profilePhoto");
    } catch (e) {}
  }

  @override
  void setFromSignUpForm(BaseUserSignUpForm experSignUpForm) {
    try {
      name = experSignUpForm.values["name"];
    } catch (e) {}
    try {
      surname = experSignUpForm.values["surname"];
    } catch (e) {}
    try {
      birthDate = experSignUpForm.values["birthDate"];
    } catch (e) {}
    try {
      email = experSignUpForm.values["email"];
    } catch (e) {}
    try {
      latitude = experSignUpForm.values["lat"];
    } catch (e) {}
    try {
      longitude = experSignUpForm.values["lng"];
    } catch (e) {}
    try {
      address = experSignUpForm.values["address"];
    } catch (e) {}
    try {
      phoneNumber = experSignUpForm.values["phoneNumber"];
    } catch (e) {}
    try {
      profilePhoto = experSignUpForm.values["profilePhoto"];
    } catch (e) {}
  }

  @override
  Map getData() {
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
