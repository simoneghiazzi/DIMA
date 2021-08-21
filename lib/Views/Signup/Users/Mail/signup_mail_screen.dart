import 'package:flutter/material.dart';
import 'components/mail_body.dart';

class SignUpMail extends StatelessWidget {
  final authViewModel;
  final String name, surname;
  final String birthDate;

  SignUpMail(
      {Key key,
      this.authViewModel,
      @required this.name,
      @required this.surname,
      @required this.birthDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MailBody(
        authViewModel: authViewModel,
        name: name,
        surname: surname,
        birthDate: birthDate,
      ),
    );
  }
}
