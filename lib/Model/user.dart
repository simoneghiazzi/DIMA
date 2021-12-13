import 'package:sApport/Model/db_item.dart';

abstract class User extends DbItem {
  String homePageRoute;
  String name;
  String surname;
  DateTime birthDate;
  String email;

  User(String collection, this.homePageRoute, {String id, this.name, this.surname, this.birthDate, this.email}) : super(collection, id: id);
}
