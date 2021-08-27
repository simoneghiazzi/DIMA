import 'package:dima_colombo_ghiazzi/Model/db_item.dart';

abstract class User implements DbItem {
  String id;
  String name;
  String surname;
  DateTime birthDate;

  User({this.id, this.name, this.surname, this.birthDate});
}
