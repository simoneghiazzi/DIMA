import 'package:google_maps_flutter/google_maps_flutter.dart';

class LoggedUser {
  String name;
  String surname;
  String eid;
  DateTime dateOfBirth;
  LatLng address;
  String country, city, street;
  int addressNumber;
  String phoneNumber;

  LoggedUser(
      {this.name,
      this.surname,
      this.eid,
      this.dateOfBirth,
      this.address,
      this.addressNumber,
      this.city,
      this.country,
      this.phoneNumber,
      this.street});
}
