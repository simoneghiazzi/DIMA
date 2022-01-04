import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Views/Home/Expert/expert_home_page_screen.dart';
import 'package:test/test.dart';
import 'package:sApport/Model/utils.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() async {
  /// Fake Firebase
  final fakeFirebase = FakeFirebaseFirestore();

  /// Mock Fields
  var id = Utils.randomId();
  var name = "Luca";
  var surname = "Colombo";
  var email = "luca.colombo@prova.it";
  var birthDate = DateTime(1997, 10, 19);
  var latitude = 0.0;
  var longitude = 0.0;
  var address = "Via Tal dei Tali, 13";
  var phoneNumber = "331331331";
  var profilePhoto = "Link to the profile photo";

  /// Mock BaseUser
  Expert mockExpert = Expert(
    id: id,
    name: name,
    surname: surname,
    email: email,
    birthDate: birthDate,
    latitude: latitude,
    longitude: longitude,
    address: address,
    phoneNumber: phoneNumber,
    profilePhoto: profilePhoto,
  );

  /// Add the mock base user to the fakeFirebase
  fakeFirebase.collection(mockExpert.collection).doc(mockExpert.id).set(mockExpert.data);

  group("Expert initialization", () {
    test("Expert collection", () {
      expect(mockExpert.collection, Expert.COLLECTION);
    });

    test("Expert home page route", () {
      expect(mockExpert.homePageRoute, ExpertHomePageScreen.route);
    });
  });

  group("Expert data", () {
    test("Expert factory from document", () async {
      var result = (await fakeFirebase.collection(mockExpert.collection).doc(mockExpert.id).get());
      var retrievedExpert = Expert.fromDocument(result);
      expect(retrievedExpert.id, id);
      expect(retrievedExpert.name, name);
      expect(retrievedExpert.surname, surname);
      expect(retrievedExpert.birthDate, birthDate);
      expect(retrievedExpert.email, email);
      expect(retrievedExpert.latitude, latitude);
      expect(retrievedExpert.longitude, longitude);
      expect(retrievedExpert.address, address);
      expect(retrievedExpert.phoneNumber, phoneNumber);
      expect(retrievedExpert.profilePhoto, profilePhoto);
    });

    test("Set expert fields from document", () async {
      var result = (await fakeFirebase.collection(mockExpert.collection).doc(mockExpert.id).get());
      var retrievedExpert = Expert();
      retrievedExpert.setFromDocument(result);
      expect(retrievedExpert.id, id);
      expect(retrievedExpert.name, name);
      expect(retrievedExpert.surname, surname);
      expect(retrievedExpert.birthDate, birthDate);
      expect(retrievedExpert.email, email);
      expect(retrievedExpert.latitude, latitude);
      expect(retrievedExpert.longitude, longitude);
      expect(retrievedExpert.address, address);
      expect(retrievedExpert.phoneNumber, phoneNumber);
      expect(retrievedExpert.profilePhoto, profilePhoto);
    });

    test("Get expert data as a key-value map", () async {
      expect(mockExpert.data, {
        "eid": id,
        "name": name,
        "surname": surname,
        "birthDate": birthDate,
        "address": address,
        "lat": latitude,
        "lng": longitude,
        "phoneNumber": phoneNumber,
        "email": email,
        "profilePhoto": profilePhoto,
      });
    });
  });
}
