import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/Experts/signup_experts_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'components/mail_experts_body.dart';

class SignUpExpertsMail extends StatelessWidget {
  final AuthViewModel authViewModel;
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
      body: WillPopScope(
        child: MailExpertsBody(
          authViewModel: authViewModel,
          name: name,
          surname: surname,
          birthDate: birthDate,
          latLng: latLng,
          phoneNumber: phoneNumber,
        ),
        onWillPop: () async =>
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
          builder: (context) {
            return SignUpExperts(authViewModel: authViewModel);
          },
        ), (route) => true),
      ),
    );
  }
}
