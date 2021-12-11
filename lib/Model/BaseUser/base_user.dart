import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/user.dart';
import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/ViewModel/Forms/base_user_signup_form.dart';

class BaseUser extends User {
  BaseUser({String id, String name, String surname, DateTime birthDate, String email})
      : super(id: id, name: name, surname: surname, birthDate: birthDate, email: email);

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
  void setFromSignUpForm(BaseUserSignUpForm baseUserSignUpForm) {
    try {
      name = baseUserSignUpForm.values["name"];
      surname = baseUserSignUpForm.values["surname"];
      birthDate = baseUserSignUpForm.values["birthDate"];
      email = baseUserSignUpForm.values["email"];
    } catch (e) {
      print("Error in setting the base user from the baseUser signup form: $e");
    }
  }

  @override
  Map<String, Object> getData() {
    return {
      "name": name,
      "surname": surname,
      "birthDate": birthDate,
      "email": email,
    };
  }

  @override
  Collection get collection => Collection.BASE_USERS;
}
