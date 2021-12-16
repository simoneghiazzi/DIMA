import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Views/Profile/expert_profile_screen.dart';
import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  var id = Utils.randomId();
  var name = "Simone";
  var surname = "Ghiazzi";
  var email = "simone.ghiazzi@prova.it";
  var birthDate = DateTime(1997, 10, 19);
  var latitude = 100.0;
  var longitude = 300.5;
  var address = "Piazza Leonardo da Vinci, 32, Milan, Province of Milan, Italia";
  var phoneNumber = "3333333333";
  var profilePhoto =
      "https://firebasestorage.googleapis.com/v0/b/dima-colomboghiazzi.appspot.com/o/bIIacGQvN4aGbH0UIjylSrJk7Dl2%2FprofilePhoto?alt=media&token=2a51bf5a-6f91-455d-b63b-0fffe0471081";

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

  testWidgets("Testing the correct render of an expert's profile page", (WidgetTester tester) async {
    //Create the expert profile screen page widget passing the expert's info
    await tester.pumpWidget(ExpertProfileScreen(expert: expert));

    // final imageFinder =
    final nameFinder = find.text(expert.name.toUpperCase() + " " + expert.surname.toUpperCase());
    final phoneFinder = find.text(expert.phoneNumber);
  });
}
