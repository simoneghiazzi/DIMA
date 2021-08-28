import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';
import 'package:dima_colombo_ghiazzi/Model/user.dart';

class BaseUser extends User {
  BaseUser(
      {String id,
      String name,
      String surname,
      DateTime birthDate,
      String email})
      : super(
            id: id,
            name: name,
            surname: surname,
            birthDate: birthDate,
            email: email);

  @override
  void setFromDocument(DocumentSnapshot doc) {
    try {
      id = doc.id;
    } catch (e) {}
    try {
      name = doc.get('name');
    } catch (e) {}
    try {
      surname = doc.get('surname');
    } catch (e) {}
    try {
      birthDate = doc.get('birthDate');
    } catch (e) {}
    try {
      email = doc.get('email');
    } catch (e) {}
  }

  @override
  getData() {
    return {
      'uid': id,
      'name': name,
      'surname': surname,
      'birthDate': birthDate,
      'email': email,
    };
  }

  @override
  Collection get collection => Collection.USERS;
}
