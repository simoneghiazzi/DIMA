import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Model/user.dart';
import 'package:sApport/ViewModel/Forms/base_user_signup_form.dart';

class BaseUser extends User {
  BaseUser({String id, String name, String surname, DateTime birthDate, String email})
      : super(id: id, name: name, surname: surname, birthDate: birthDate, email: email);

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
      birthDate = doc.get("birthDate").toDate();
    } catch (e) {}
    try {
      email = doc.get("email");
    } catch (e) {}
  }

  @override
  void setFromSignUpForm(BaseUserSignUpForm baseUserInfoForm) {
    try {
      name = baseUserInfoForm.values["name"];
    } catch (e) {}
    try {
      surname = baseUserInfoForm.values["surname"];
    } catch (e) {}
    try {
      birthDate = baseUserInfoForm.values["birthDate"];
    } catch (e) {}
    try {
      email = baseUserInfoForm.values["email"];
    } catch (e) {}
  }

  @override
  Map getData() {
    return {
      "uid": id,
      "name": name,
      "surname": surname,
      "birthDate": birthDate,
      "email": email,
    };
  }

  @override
  Collection get collection => Collection.BASE_USERS;
}
