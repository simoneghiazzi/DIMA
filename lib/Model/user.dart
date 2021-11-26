import 'package:sApport/Model/db_item.dart';

abstract class User implements DbItem {
  String id;
  String name;
  String surname;
  DateTime birthDate;
  String email;

  User({this.id, this.name, this.surname, this.birthDate, this.email});
}
