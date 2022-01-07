import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Views/Home/Expert/expert_home_page_screen.dart';

void main() async {
  /// Fake Firebase
  final fakeFirebase = FakeFirebaseFirestore();

  /// Test Fields
  var id = Utils.randomId();
  var name = "Luca";
  var surname = "Colombo";
  var email = "luca.colombo@prova.it";
  var birthDate = DateTime(1997, 10, 19);
  var latitude = 45.478195;
  var longitude = 9.2256787;
  var address = "Piazza Leonardo da Vince, Milano, Italia";
  var phoneNumber = "331331331";
  var profilePhoto = "Link to the profile photo";

  Expert expert = Expert(
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

  /// Add the expert to the fakeFirebase
  fakeFirebase.collection(expert.collection).doc(expert.id).set(expert.data);

  group("Expert initialization", () {
    test("Expert collection", () {
      expect(expert.collection, Expert.COLLECTION);
    });

    test("Expert home page route", () {
      expect(expert.homePageRoute, ExpertHomePageScreen.route);
    });
  });

  group("Expert data", () {
    test("Expert factory from document", () async {
      var result = (await fakeFirebase.collection(expert.collection).doc(expert.id).get());
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
      var result = (await fakeFirebase.collection(expert.collection).doc(expert.id).get());
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
      expect(expert.data, {
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
