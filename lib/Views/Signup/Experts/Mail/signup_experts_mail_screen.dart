import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'components/mail_experts_body.dart';

class SignUpExpertsMail extends StatelessWidget {
  final authViewModel;
  final String name, surname, phoneNumber;
  final DateTime birthDate;
  final LatLng latLng;

  SignUpExpertsMail(
      {Key key,
      @required this.authViewModel,
      @required this.name,
      @required this.surname,
      @required this.phoneNumber,
      @required this.birthDate,
      @required this.latLng})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MailExpertsBody(
        authViewModel: authViewModel,
        name: name,
        surname: surname,
        birthDate: birthDate,
      ),
    );
  }
}
