import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Views/Home/BaseUser/base_user_home_page_screen.dart';

void main() async {
  /// Fake Firebase
  final fakeFirebase = FakeFirebaseFirestore();

  /// Test Fields
  var id = Utils.randomId();
  var name = "Luca";
  var surname = "Colombo";
  var email = "luca.colombo@prova.it";
  var birthDate = DateTime(1997, 10, 19);

  BaseUser baseUser = BaseUser(
    id: id,
    name: name,
    surname: surname,
    email: email,
    birthDate: birthDate,
  );

  /// Add the base user to the fakeFirebase
  fakeFirebase.collection(baseUser.collection).doc(baseUser.id).set(baseUser.data);

  group("BaseUser initialization", () {
    test("Base user collection initially set to users", () {
      expect(baseUser.collection, BaseUser.COLLECTION);
    });

    test("Base user home page route initially set to /baseUserHomePageScreen", () {
      expect(baseUser.homePageRoute, BaseUserHomePageScreen.route);
    });
  });

  group("BaseUser data", () {
    test("Base user factory returns the instance with the fields retrived from the document snapshot correctly setted", () async {
      var result = (await fakeFirebase.collection(baseUser.collection).doc(baseUser.id).get());
      var retrievedBaseUser = BaseUser.fromDocument(result);
      expect(retrievedBaseUser.id, id);
      expect(retrievedBaseUser.name, name);
      expect(retrievedBaseUser.surname, surname);
      expect(retrievedBaseUser.birthDate, birthDate);
      expect(retrievedBaseUser.email, email);
    });

    test("Set base user from document sets the fields of an already created instance with the correct values retrived from the document snapshot",
        () async {
      var result = (await fakeFirebase.collection(baseUser.collection).doc(baseUser.id).get());
      var retrievedBaseUser = BaseUser();
      retrievedBaseUser.setFromDocument(result);
      expect(retrievedBaseUser.id, id);
      expect(retrievedBaseUser.name, name);
      expect(retrievedBaseUser.surname, surname);
      expect(retrievedBaseUser.birthDate, birthDate);
      expect(retrievedBaseUser.email, email);
    });

    test("Check that base user data returns a key-value map with the correct fields", () {
      expect(baseUser.data, {
        "uid": id,
        "name": name,
        "surname": surname,
        "birthDate": birthDate,
        "email": email,
      });
    });
  });
}
