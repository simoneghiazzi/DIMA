import 'package:test/test.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';

void main() async {
  /// BaseUser used for testing the User abstract class
  var loggedUser = BaseUser(
    id: Utils.randomId(),
    name: "Luca",
    surname: "Colombo",
    email: "luca.colombo@prova.it",
    birthDate: DateTime(1997, 10, 19),
  );
  test("User full name should return a string with the name and the surname of the user", () async {
    expect(loggedUser.fullName, loggedUser.name + " " + loggedUser.surname);
  });
}
