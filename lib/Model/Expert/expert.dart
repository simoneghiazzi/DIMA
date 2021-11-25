import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Model/user.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Expert extends User {
  LatLng latLng;
  String address;
  String phoneNumber;
  String profilePhoto;

  Expert(
      {String id,
      String name,
      String surname,
      DateTime birthDate,
      String email,
      this.latLng,
      this.address,
      this.phoneNumber,
      this.profilePhoto})
      : super(
            id: id,
            name: name,
            surname: surname,
            birthDate: birthDate,
            email: email);

  @override
  void setFromDocument(DocumentSnapshot doc) {
    try {
      id = doc.id;
    } catch (e) {}
    try {
      name = doc.get('name');
    } catch (e) {}
    try {
      surname = doc.get('surname');
    } catch (e) {}
    try {
      birthDate = doc.get('birthDate');
    } catch (e) {}
    try {
      latLng = LatLng(doc.get('lat'), doc.get('lng'));
    } catch (e) {}
    try {
      address = doc.get('address');
    } catch (e) {}
    try {
      email = doc.get('email');
    } catch (e) {}
    try {
      phoneNumber = doc.get('phoneNumber');
    } catch (e) {}
    try {
      profilePhoto = doc.get('profilePhoto');
    } catch (e) {}
  }

  @override
  getData() {
    return {
      'eid': id,
      'name': name,
      'surname': surname,
      'birthDate': birthDate,
      'address': address,
      'lat': latLng.latitude,
      'lng': latLng.longitude,
      'phoneNumber': phoneNumber,
      'email': email,
      'profilePhoto': profilePhoto
    };
  }

  @override
  Collection get collection => Collection.EXPERTS;
}
