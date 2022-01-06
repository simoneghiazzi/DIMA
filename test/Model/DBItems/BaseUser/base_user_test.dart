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
    test("Base user collection", () {
      expect(baseUser.collection, BaseUser.COLLECTION);
    });

    test("Base user home page route", () {
      expect(baseUser.homePageRoute, BaseUserHomePageScreen.route);
    });
  });

  group("BaseUser data", () {
    test("Base user factory from document", () async {
      var result = (await fakeFirebase.collection(baseUser.collection).doc(baseUser.id).get());
      var retrievedBaseUser = BaseUser.fromDocument(result);
      expect(retrievedBaseUser.id, id);
      expect(retrievedBaseUser.name, name);
      expect(retrievedBaseUser.surname, surname);
      expect(retrievedBaseUser.birthDate, birthDate);
      expect(retrievedBaseUser.email, email);
    });

    test("Set base user from document", () async {
      var result = (await fakeFirebase.collection(baseUser.collection).doc(baseUser.id).get());
      var retrievedBaseUser = BaseUser();
      retrievedBaseUser.setFromDocument(result);
      expect(retrievedBaseUser.id, id);
      expect(retrievedBaseUser.name, name);
      expect(retrievedBaseUser.surname, surname);
      expect(retrievedBaseUser.birthDate, birthDate);
      expect(retrievedBaseUser.email, email);
    });

    test("Get base user data as a key-value map", () async {
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
