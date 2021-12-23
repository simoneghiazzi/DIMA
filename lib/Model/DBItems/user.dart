import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/DBItems/db_item.dart';

abstract class User extends DbItem {
  String homePageRoute;
  String name;
  String surname;
  DateTime? birthDate;
  String email;

  User(String collection, this.homePageRoute, {String id = "", this.name = "", this.surname = "", this.birthDate, this.email = ""})
      : super(collection, id: id);

  /// Set dinamically the fields of the [User] from the [doc].
  void setFromDocument(DocumentSnapshot doc);

  String get fullName => "$name $surname";
}
